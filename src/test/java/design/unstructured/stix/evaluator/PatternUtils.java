package design.unstructured.stix.evaluator;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;
import com.fasterxml.jackson.databind.JsonMappingException;

public class PatternUtils {

    static class PatternList extends ArrayList<StixPattern> {

        private static final long serialVersionUID = 1L;

        void evaluateAll() throws ParseException, StixPatternProcessorException {
            for (StixPattern stixPattern : this) {
                Pattern pattern = Pattern.build(stixPattern.getPattern());

                if (pattern == null) {
                    throw new StixPatternProcessorException("Unable to parse pattern: " + stixPattern.getPattern());
                }

                stixPattern.setParsedPattern(pattern);
            }
        }
    }

    static PatternList loadPatternFile(File patternFile)
            throws IllegalStateException, JsonParseException, JsonMappingException, IOException {

        PatternList patterns = new PatternList();

        try (JsonParser parser = JacksonMapperProvider.getReader().getFactory().createParser(patternFile)) {
            if (parser.nextToken() != JsonToken.START_ARRAY) {
                throw new IllegalStateException("Expected an array");
            }

            while (parser.nextToken() == JsonToken.START_OBJECT) {
                StixPattern rule = JacksonMapperProvider.getMapper().readValue(parser, StixPattern.class);
                patterns.add(rule);
            }
        }
        return patterns;
    }
}