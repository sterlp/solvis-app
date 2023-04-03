package org.sterl.solvis.v2.stub;

import java.io.IOException;
import java.io.InputStream;

import org.apache.commons.io.IOUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SolvisResource {
    
    enum States {
        HOME("/display_home.bmp"),
        HEIZUNG("/display_heizung.bmp"),
        ;

        private States(String file) {
			this.file = file;
		}

        private final String file;

		public String getFile() {
			return file;
		}
    }
    
    private States state = States.HOME;

    @GetMapping(value = "/", produces = "image/bmp")
    byte[] home() throws IOException {
    	sleep(250);
        try (InputStream in = getClass().getResourceAsStream(state.getFile())) {
            return IOUtils.toByteArray(in);
        }
    }

    @GetMapping(value = "display.bmp", produces = "image/bmp")
    byte[] display() throws IOException {
    	sleep(250);
        try (InputStream in = getClass().getResourceAsStream(state.getFile())) {
            return IOUtils.toByteArray(in);
        }
    }
    
    // x=510&y=510
    @GetMapping("/Touch.CGI")
    public void touch(
    		@RequestParam(value =  "x", required = false, defaultValue = "0") int x, 
    		@RequestParam(value = "y", required = false, defaultValue = "0") int y) {

    	sleep(250);
        if (x == 510 && y == 510) {
            if (state == States.HOME) state = States.HEIZUNG;
            else state = States.HOME;
        }
    }
        
    // Taster.CGI?taste=links&i=49019573
    @GetMapping("/Taster.CGI")
    public void taste(@RequestParam("taste") String taste) {
    	sleep(250);
    	state = States.HOME;
    }
    
    private void sleep(int ms) {
    	try {
			Thread.sleep(ms);
		} catch (InterruptedException e) {
		}
    }
}
