package com.healthcare.dashboard.config;

import org.junit.jupiter.api.Test;
import org.springframework.web.client.RestTemplate;

import static org.assertj.core.api.Assertions.assertThat;

class RestTemplateConfigTest {

    @Test
    void restTemplate_ShouldBeCreated() {
        RestTemplateConfig config = new RestTemplateConfig();
        RestTemplate restTemplate = config.restTemplate();

        assertThat(restTemplate).isNotNull();
    }

    @Test
    void restTemplate_ShouldBeInstanceOfRestTemplate() {
        RestTemplateConfig config = new RestTemplateConfig();
        RestTemplate restTemplate = config.restTemplate();

        assertThat(restTemplate).isInstanceOf(RestTemplate.class);
    }
}
