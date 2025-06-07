# Cloudflare

Tryby SSL:
- Strict – wymuszanie połączenia po SSL, nawet jeśli użytkownik jednoznacznie poprosi o wersję nieszyfrowaną strony.
- Full (strict) – Twoja aplikacja MUSI podawać szyfrowaną zawartość i MUSI używać w tym celu certyfikatu SSL pochodzącego od Cloudflare (możesz go wygenerować w panelu użytkownika)
- Full – działa jak opcja wyżej, ale możesz posłużyć się absolutnie dowolnego certyfikatu, w tym także samopodpisanego (self-signed). Jest to bardzo często używana opcja. Łatwa do wdrożenia i bezpieczna.
- Flexible – ruch od użytkownika do Cloudflare będzie szyfrowany (HTTPS), ale już od Cloudflare do backandu będzie przebiegał czystym tekstem (HTTP). To częste rozwiązanie, gdy Twoja aplikacja nie umie szyfrować danych, ale chcesz zapewnić użytkownikom bezpieczeństwo.
- Off – zupełne wyłączenie wsparcia dla SSL. Nie używaj tej opcji.