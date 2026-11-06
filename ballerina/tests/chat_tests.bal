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

import ballerina/ai;
import ballerina/test;

const CHAT_SERVICE_URL = "http://localhost:8081/chat";

final ModelProvider reasoningProvider = check new (API_KEY, MISTRAL_LARGE_4_0, CHAT_SERVICE_URL,
    reasoningEffort = "high"
);

@test:Config
function testNewModelNames() returns error? {
    MISTRAL_AI_MODEL_NAMES[] modelNames = [MISTRAL_LARGE_4, MISTRAL_LARGE_4_0, MISTRAL_SMALL_2603,
        MINISTRAL_3B_2512, MINISTRAL_8B_2512, MINISTRAL_14B_2512, CODESTRAL_2508];
    foreach MISTRAL_AI_MODEL_NAMES modelName in modelNames {
        ModelProvider provider = check new (API_KEY, modelName, CHAT_SERVICE_URL);
        map<json> request = check getEchoedRequest(provider);
        test:assertEquals(request["model"], modelName);
    }
}

@test:Config
function testReasoningEffortOnNonReasoningModel() {
    ModelProvider|ai:Error provider = new (API_KEY, MINISTRAL_8B_2512, CHAT_SERVICE_URL, reasoningEffort = "high");
    if provider !is ai:Error {
        test:assertFail("Expected an ai:Error");
    }
    test:assertEquals(provider.message(),
            "The model 'ministral-8b-2512' does not support the 'reasoningEffort' configuration.");
}

@test:Config
function testUnsupportedReasoningEffortForModel() {
    ModelProvider|ai:Error provider = new (API_KEY, MISTRAL_SMALL_2603, CHAT_SERVICE_URL, reasoningEffort = "low");
    if provider !is ai:Error {
        test:assertFail("Expected an ai:Error");
    }
    test:assertEquals(provider.message(),
            "The model 'mistral-small-2603' does not support the reasoning effort 'low'. Supported values: none, high.");
}

@test:Config
function testReasoningEffortOnLatestAlias() returns error? {
    ModelProvider provider = check new (API_KEY, MISTRAL_SMALL_LATEST, CHAT_SERVICE_URL, reasoningEffort = "high");
    map<json> request = check getEchoedRequest(provider);
    test:assertEquals(request["reasoning_effort"], "high");
}

@test:Config
function testDefaultRequestConfigurations() returns error? {
    ModelProvider provider = check new (API_KEY, MISTRAL_SMALL_2603, CHAT_SERVICE_URL);
    map<json> request = check getEchoedRequest(provider);
    test:assertEquals(request["max_tokens"], 4096);
    test:assertEquals(request["has_reasoning_effort"], false);
}

@test:Config
function testReasoningEffortInChat() returns error? {
    map<json> request = check getEchoedRequest(reasoningProvider);
    test:assertEquals(request["model"], MISTRAL_LARGE_4_0);
    test:assertEquals(request["reasoning_effort"], "high");
}

@test:Config
function testReasoningEffortInGenerate() returns error? {
    string reasoningEffort = check reasoningProvider->generate(`What is the configured reasoning effort?`);
    test:assertEquals(reasoningEffort, "high");
}

@test:Config
function testChatWithThinkingChunks() returns ai:Error? {
    ai:ChatAssistantMessage response = check reasoningProvider->chat([{role: ai:USER, content: "thinking"}], []);
    test:assertEquals(response.content, "The answer is 5.");
}

@test:Config
function testChatWithChunkedTextContent() returns ai:Error? {
    ai:ChatAssistantMessage response = check reasoningProvider->chat([{role: ai:USER, content: "chunked"}], []);
    test:assertEquals(response.content, "Hello, world!");
}

@test:Config
function testChatWithUnsupportedContentChunk() {
    ai:ChatAssistantMessage|ai:Error response = reasoningProvider->chat([{role: ai:USER, content: "unsupported"}], []);
    if response !is ai:LlmInvalidResponseError {
        test:assertFail("Expected an ai:LlmInvalidResponseError");
    }
    test:assertEquals(response.message(), "Unsupported content type 'image_url' in the response");
}

@test:Config
function testChatWithMultipleToolCallsInHistory() returns error? {
    ai:ChatMessage[] messages = [
        {role: ai:USER, content: "What is the weather in Paris and London?"},
        {
            role: ai:ASSISTANT,
            toolCalls: [
                {name: "getWeather", arguments: {city: "Paris"}, id: "callParis"},
                {name: "getWeather", arguments: {city: "London"}, id: "callLondon"}
            ]
        },
        {role: "function", name: "getWeather", id: "callParis", content: "Sunny"},
        {role: "function", name: "getWeather", id: "callLondon", content: "Rainy"},
        {role: ai:USER, content: "tool-history"}
    ];
    ai:ChatAssistantMessage response = check reasoningProvider->chat(messages, []);
    string? content = response.content;
    if content is () {
        return error("Expected the echoed assistant message");
    }
    json assistantMessage = check content.fromJsonString();
    test:assertEquals(assistantMessage, {
        "role": "assistant",
        "prefix": false,
        "content": null,
        "tool_calls": [
            {
                "function": {"name": "getWeather", "arguments": "{\"city\":\"Paris\"}"},
                "index": 0,
                "id": "callParis"
            },
            {
                "function": {"name": "getWeather", "arguments": "{\"city\":\"London\"}"},
                "index": 0,
                "id": "callLondon"
            }
        ]
    });
}

function getEchoedRequest(ModelProvider provider) returns map<json>|error {
    ai:ChatAssistantMessage response = check provider->chat([{role: ai:USER, content: "echo-request"}], []);
    string? content = response.content;
    if content is () {
        return error("Expected the echoed request");
    }
    return content.fromJsonStringWithType();
}
