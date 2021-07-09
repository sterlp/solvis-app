package org.sterl.solvis.v2.stub;

import java.io.IOException;
import java.io.InputStream;

import org.apache.commons.io.IOUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.Data;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

@RestController
public class SolvisResource {
    
    @RequiredArgsConstructor
    enum States {
        HOME("/display_home.bmp"),
        HEIZUNG("/display_heizung.bmp"),
        ;

        @Getter
        private final String file;
    }
    
    private States state = States.HOME;

    @RequestMapping(value = "display.bmp", method = RequestMethod.GET, produces = "image/bmp")
    byte[] display() throws IOException {
        try (InputStream in = getClass().getResourceAsStream(state.getFile())) {
            return IOUtils.toByteArray(in);
        }
    }
    
    // x=510&y=510
    @RequestMapping(value = "/Touch.CGI", method = RequestMethod.GET)
    void touch(@RequestParam("x") int x, @RequestParam("y") int y) {
        if (x == 510 && y == 510) {
            if (state == States.HOME) state = States.HEIZUNG;
            else state = States.HOME;
        }
    }
}
