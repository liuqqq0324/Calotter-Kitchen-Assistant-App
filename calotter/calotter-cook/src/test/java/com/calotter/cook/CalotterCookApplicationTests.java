package com.calotter.cook;

import com.calotter.cook.service.ISessionService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

@SpringBootTest
class CalotterCookApplicationTests {

    @Autowired
    ISessionService sessionService;

    @Test
    void contextLoads() {
        sessionService.deleteWithValidByIds(List.of(3L), true);
    }

}
