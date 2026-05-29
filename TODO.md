# TODO

## Gemini chatbot fix
- [ ] Inspect GeminiService implementation and current error handling
- [ ] Verify API key handling and model name usage
- [ ] Replace generic fallback with proper logging + return null/throw on real failure
- [ ] Add extra debug prints (Gemini response / error)
- [ ] Ensure response.text is non-null before displaying
- [ ] Update UI to avoid showing empty responses (e.g., show error message only when truly failed)
- [ ] Ensure Android INTERNET permission exists (already present)
- [x] Run flutter analyze / tests / build (if available)


