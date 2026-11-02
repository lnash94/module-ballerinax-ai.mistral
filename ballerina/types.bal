// Copyright (c) 2025 WSO2 LLC (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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
import ballerinax/mistral;

# Configurations for controlling the behaviours when communicating with a remote HTTP endpoint.
@display {label: "Connection Configuration"}
public type ConnectionConfig record {|

    # The HTTP version understood by the client
    @display {label: "HTTP Version"}
    http:HttpVersion httpVersion = http:HTTP_2_0;

    # Configurations related to HTTP/1.x protocol
    @display {label: "HTTP1 Settings"}
    http:ClientHttp1Settings http1Settings?;

    # Configurations related to HTTP/2 protocol
    @display {label: "HTTP2 Settings"}
    http:ClientHttp2Settings http2Settings?;

    # The maximum time to wait (in seconds) for a response before closing the connection
    @display {label: "Timeout"}
    decimal timeout = 60;

    # The choice of setting `forwarded`/`x-forwarded` header
    @display {label: "Forwarded"}
    string forwarded = "disable";

    # Configurations associated with request pooling
    @display {label: "Pool Configuration"}
    http:PoolConfiguration poolConfig?;

    # HTTP caching related configurations
    @display {label: "Cache Configuration"}
    http:CacheConfig cache?;

    # Specifies the way of handling compression (`accept-encoding`) header
    @display {label: "Compression"}
    http:Compression compression = http:COMPRESSION_AUTO;

    # Configurations associated with the behaviour of the Circuit Breaker
    @display {label: "Circuit Breaker Configuration"}
    http:CircuitBreakerConfig circuitBreaker?;

    # Configurations associated with retrying
    @display {label: "Retry Configuration"}
    http:RetryConfig retryConfig?;

    # Configurations associated with inbound response size limits
    @display {label: "Response Limit Configuration"}
    http:ResponseLimitConfigs responseLimits?;

    # SSL/TLS-related options
    @display {label: "Secure Socket Configuration"}
    http:ClientSecureSocket secureSocket?;

    # Proxy server related options
    @display {label: "Proxy Configuration"}
    http:ProxyConfig proxy?;

    # Enables the inbound payload validation functionality which provided by the constraint package. Enabled by default
    @display {label: "Payload Validation"}
    boolean validation = true;
|};

# Model types for Mistral AI.
# The model type of the `ModelProvider` also accepts any other Mistral AI model name as a `string`,
# which allows using models that are not listed here.
@display {label: "Mistral AI Model Names"}
public enum MISTRAL_AI_MODEL_NAMES {
    MISTRAL_SMALL_LATEST = "mistral-small-latest",
    MISTRAL_MEDIUM_LATEST = "mistral-medium-latest",
    MISTRAL_LARGE_LATEST = "mistral-large-latest",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    DEVSTRAL_SMALL_LATEST = "devstral-small-latest",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    PIXTRAL_LARGE_LATEST = "pixtral-large-latest",
    MINISTRAL_3B_LATEST = "ministral-3b-latest",
    MINISTRAL_8B_LATEST = "ministral-8b-latest",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MISTRAL_SABA_LATEST = "mistral-saba-latest",
    CODESTRAL_LATEST = "codestral-latest",
    # Mistral Large 4 (v26.10)
    MISTRAL_LARGE_4 = "mistral-large-4",
    # Mistral Large 4 (v26.10)
    MISTRAL_LARGE_4_0 = "mistral-large-4-0",
    # Mistral Small 4 (v26.03)
    MISTRAL_SMALL_2603 = "mistral-small-2603",
    # Ministral 3 3B (v25.12)
    MINISTRAL_3B_2512 = "ministral-3b-2512",
    # Ministral 3 8B (v25.12)
    MINISTRAL_8B_2512 = "ministral-8b-2512",
    # Ministral 3 14B (v25.12)
    MINISTRAL_14B_2512 = "ministral-14b-2512",
    # Codestral (v25.08)
    CODESTRAL_2508 = "codestral-2508",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MISTRAL_SMALL_2402 = "mistral-small-2402",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MISTRAL_SMALL_2409 = "mistral-small-2409",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MISTRAL_SMALL_2501 = "mistral-small-2501",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MISTRAL_SMALL_2503 = "mistral-small-2503",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MINISTRAL_3B_2410 = "ministral-3b-2410",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MINISTRAL_8B_2410 = "ministral-8b-2410",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MISTRAL_MEDIUM_2312 = "mistral-medium-2312",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MISTRAL_MEDIUM_2505 = "mistral-medium-2505",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MISTRAL_LARGE_2402 = "mistral-large-2402",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MISTRAL_LARGE_2407 = "mistral-large-2407",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MISTRAL_LARGE_2411 = "mistral-large-2411",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    MISTRAL_SABA_2502 = "mistral-saba-2502",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    CODESTRAL_2405 = "codestral-2405",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    CODESTRAL_2501 = "codestral-2501",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    CODESTRAL_MAMBA_2407 = "codestral-mamba-2407",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    DEVSTRAL_SMALL_2505 = "devstral-small-2505",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    OPEN_MISTRAL_7B = "open-mistral-7b",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    OPEN_MISTRAL_NEMO = "open-mistral-nemo",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    OPEN_MIXTRAL_8X7B = "open-mixtral-8x7b",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    OPEN_MIXTRAL_8X22B = "open-mixtral-8x22b",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    PIXTRAL_LARGE_2411 = "pixtral-large-2411",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    PIXTRAL_12B_2409 = "pixtral-12b-2409",
    # # Deprecated
    # This model is deprecated or retired by Mistral AI. Use a current model instead.
    @deprecated
    OPEN_CODESTRAL_MAMBA = "open-codestral-mamba"
}

# Reasoning effort for reasoning-capable Mistral AI models.
# The supported values vary by model. Refer to the [Mistral AI reasoning documentation](https://docs.mistral.ai/capabilities/reasoning/).
@display {label: "Reasoning Effort"}
public type ReasoningEffort "none"|"minimal"|"low"|"medium"|"high"|"xhigh";

# Mistral message record.
type MistralMessages mistral:AssistantMessage|mistral:SystemMessage|mistral:UserMessage|mistral:ToolMessage;
