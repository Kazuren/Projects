using System.Threading.Tasks;

using System.Collections.Generic;

using System.Net.Http;

using System.Text.Json;
using System.Text.Json.Serialization;

namespace Twitch
{
  public static class TokenManager
  {
    public class OAuthTokenResponse
    {
      [JsonPropertyName("access_token")]
      [JsonInclude]
      public string AccessToken { get; private set; }

      [JsonPropertyName("expires_in")]
      [JsonInclude]
      public int ExpiresIn { get; private set; }

      [JsonPropertyName("token_type")]
      [JsonInclude]
      public string TokenType { get; private set; }
    }

    public static async Task<string> GetToken()
    {
      using (var request = new HttpRequestMessage(HttpMethod.Post, $"https://id.twitch.tv/oauth2/token"))
      {
        request.Content = new FormUrlEncodedContent(new[]
        {
          new KeyValuePair<string, string>("client_id", Client.ClientId),
          new KeyValuePair<string, string>("client_secret", Client.ClientSecret),
          new KeyValuePair<string, string>("grant_type", "client_credentials"),
        });
        HttpResponseMessage response = await Client.HttpClient.SendAsync(request);
        response.EnsureSuccessStatusCode();
        string responseBody = await response.Content.ReadAsStringAsync();

        OAuthTokenResponse oAuthTokenResponse = JsonSerializer.Deserialize<OAuthTokenResponse>(responseBody);

        return oAuthTokenResponse.AccessToken;
      }
    }
  }
}
