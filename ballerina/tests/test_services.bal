// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.org).
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/test;
import ballerinax/mistral;

service /llm on new http:Listener(8080) {
    // bug: https://github.com/ballerina-platform/ballerina-library/issues/8048
    resource function post chat/completions(@http:Payload json payload)returns mistral:ChatCompletionResponse|error {
        test:assertEquals(payload.model, MINISTRAL_8B_2512);
        test:assertEquals(payload.temperature, 0.1d);
        test:assertEquals(payload.max_tokens, 100);

        json[] messages = check payload.messages.ensureType();
        map<json> message = check (messages[0]).fromJsonWithType();
        json[] content = check message.content.ensureType();
        mistral:TextChunk initialTextContent = check content[0].fromJsonWithType();
        string initialText = initialTextContent.text;
        test:assertEquals(content, getExpectedContentParts(initialText));
        test:assertEquals(message.role, "user");
        json[]? tools = check payload?.tools.ensureType();
        if tools is () || tools.length() == 0 {
            test:assertFail("No tools in the payload");
        }

        mistral:Tool tool = check tools[0].fromJsonWithType();
        record {} parameters = tool.'function.parameters;
        if parameters == {} {
            test:assertFail("No parameters in the expected tool in the test with content: " + initialText);
        }

        test:assertEquals(parameters, getExpectedParameterSchema(initialText));
        return getTestServiceResponse(initialText);
    }
}

service /chat on new http:Listener(8081) {
    resource function post chat/completions(@http:Payload map<json> payload) returns json|error {
        if payload.hasKey("tools") {
            // Generate requests: return the configured reasoning effort as the tool call result.
            return getChatServiceResponse([THINKING_CHUNK], [
                {
                    id: "getResultsCall",
                    'type: "function",
                    'function: {
                        name: GET_RESULTS_TOOL,
                        arguments: {result: payload["reasoning_effort"]}.toJsonString()
                    }
                }
            ]);
        }

        json[] messages = check payload["messages"].ensureType();
        map<json> lastMessage = check messages[messages.length() - 1].ensureType();
        string scenario = check lastMessage["content"].ensureType();
        match scenario {
            "echo-request" => {
                return getChatServiceResponse({
                    model: payload["model"],
                    max_tokens: payload["max_tokens"],
                    reasoning_effort: payload["reasoning_effort"],
                    has_reasoning_effort: payload.hasKey("reasoning_effort")
                }.toJsonString());
            }
            "thinking" => {
                return getChatServiceResponse([
                    THINKING_CHUNK,
                    {'type: "text", text: "The answer "},
                    {'type: "text", text: "is 5."}
                ]);
            }
            "chunked" => {
                return getChatServiceResponse([{'type: "text", text: "Hello, "}, {'type: "text", text: "world!"}]);
            }
            "unsupported" => {
                return getChatServiceResponse([{'type: "image_url", image_url: "https://example.com/image.png"}]);
            }
            "tool-history" => {
                return getChatServiceResponse(messages[1].toJsonString());
            }
        }
        return error("Unknown test scenario: " + scenario);
    }
}

final json & readonly THINKING_CHUNK = {
    'type: "thinking",
    thinking: [{'type: "text", text: "The user wants the sum of 2 and 3, which is 5."}]
};

isolated function getChatServiceResponse(json content, json toolCalls = ()) returns json => {
    id: "chatcmpl-test",
    'object: "chat.completion",
    model: "mistral-large-4-0",
    created: 1761811200,
    usage: {prompt_tokens: 10, completion_tokens: 20, total_tokens: 30},
    choices: [
        {
            index: 0,
            finish_reason: toolCalls is () ? "stop" : "tool_calls",
            message: {role: "assistant", content, tool_calls: toolCalls}
        }
    ]
};
