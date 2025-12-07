package com.souschef.controller;

import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@RestController
@RequestMapping("/WeatherForecast")
@CrossOrigin(origins = "*")
public class WeatherForecastController {
    
    private static final String[] SUMMARIES = {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", 
        "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };
    
    @GetMapping
    public List<WeatherForecast> get() {
        List<WeatherForecast> forecasts = new ArrayList<>();
        Random random = new Random();
        
        for (int i = 1; i <= 5; i++) {
            WeatherForecast forecast = new WeatherForecast();
            forecast.setDate(LocalDate.now().plusDays(i));
            forecast.setTemperatureC(random.nextInt(-20, 55));
            forecast.setSummary(SUMMARIES[random.nextInt(SUMMARIES.length)]);
            forecasts.add(forecast);
        }
        
        return forecasts;
    }
    
    public static class WeatherForecast {
        private LocalDate date;
        private Integer temperatureC;
        private String summary;
        
        public LocalDate getDate() {
            return date;
        }
        
        public void setDate(LocalDate date) {
            this.date = date;
        }
        
        public Integer getTemperatureC() {
            return temperatureC;
        }
        
        public void setTemperatureC(Integer temperatureC) {
            this.temperatureC = temperatureC;
        }
        
        public String getSummary() {
            return summary;
        }
        
        public void setSummary(String summary) {
            this.summary = summary;
        }
    }
}


