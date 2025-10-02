package com.example.demo;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import java.io.IOException;

public class CommaToLongDeserializer extends JsonDeserializer<Long> {
    @Override
    public Long deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
        String value = p.getText().replace(",", "");
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException e) {
            return null; // 또는 0L 등 기본값 사용 가능
        }
    }
}