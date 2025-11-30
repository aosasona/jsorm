-module(jsorm_ffi).
-export([generate_otp/0]).

generate_otp() ->
    %% Get 3 crypto-secure random bytes
    <<A:8, B:8, C:8>> = crypto:strong_rand_bytes(3),

    %% Convert to a single integer
    Value = A * 256 * 256 + B * 256 + C,

    %% Restrict to six digits max
    OTP = Value rem 1000000,

    %% Format padded with leading zeros
    list_to_binary(io_lib:format("~6..0B", [OTP])).

