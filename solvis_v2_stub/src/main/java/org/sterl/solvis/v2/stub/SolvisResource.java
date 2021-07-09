package org.sterl.solvis.v2.stub;

import java.io.IOException;
import java.io.InputStream;

import org.apache.commons.io.IOUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SolvisResource {

    @RequestMapping(value = "display.bmp", method = RequestMethod.GET, produces = "image/bmp")
    byte[] display() throws IOException {
        try (InputStream in = getClass().getResourceAsStream("/display_home.bmp")) {
            return IOUtils.toByteArray(in);
        }
    }
}
