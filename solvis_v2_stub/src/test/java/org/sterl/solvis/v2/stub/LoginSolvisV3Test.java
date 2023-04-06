package org.sterl.solvis.v2.stub;

import java.net.URI;

import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.AuthCache;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.HttpClient;
import org.apache.http.client.protocol.ClientContext;
import org.apache.http.impl.auth.DigestScheme;
import org.apache.http.impl.client.BasicAuthCache;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpMethod;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

@Disabled
class LoginSolvisV3Test {

    @Test
    void test() {
        RestTemplate subject = restTemplate();

        System.out.println( subject.getForEntity("http://192.168.188.110/remote.html", String.class) );
    }
    
    public RestTemplate restTemplate() {
        HttpHost host = new HttpHost("localhost", 8080, "http");
        CloseableHttpClient client = HttpClientBuilder.create().
          setDefaultCredentialsProvider(provider()).useSystemProperties().build();
        HttpComponentsClientHttpRequestFactory requestFactory = 
          new HttpComponentsClientHttpRequestFactoryDigestAuth(host, client);

        return new RestTemplate(requestFactory);
    }
    
    private CredentialsProvider provider() {
        CredentialsProvider provider = new BasicCredentialsProvider();
        UsernamePasswordCredentials credentials = 
          new UsernamePasswordCredentials("Solvis", "RCSC3!"); // RCSC3!
        provider.setCredentials(AuthScope.ANY, credentials);
        return provider;
    }
    
    public class HttpComponentsClientHttpRequestFactoryDigestAuth 
    extends HttpComponentsClientHttpRequestFactory {

      HttpHost host;

      public HttpComponentsClientHttpRequestFactoryDigestAuth(HttpHost host, HttpClient httpClient) {
          super(httpClient);
          this.host = host;
      }

      @Override
      protected HttpContext createHttpContext(HttpMethod httpMethod, URI uri) {
          return createHttpContext();
      }

      private HttpContext createHttpContext() {
          // Create AuthCache instance
          AuthCache authCache = new BasicAuthCache();
          // Generate DIGEST scheme object, initialize it and add it to the local auth cache
          DigestScheme digestAuth = new DigestScheme();
          // If we already know the realm name
          //digestAuth.overrideParamter("realm", "Custom Realm Name");
          authCache.put(host, digestAuth);

          // Add AuthCache to the execution context
          BasicHttpContext localcontext = new BasicHttpContext();
          localcontext.setAttribute(ClientContext.AUTH_CACHE, authCache);
          return localcontext;
      }
  }

}
