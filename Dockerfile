FROM swift:5.3 as builder
WORKDIR /app
COPY . .
RUN swift build -c release

FROM swift:5.3-slim
WORKDIR /app
COPY --from=builder /app/.build/x86_64-unknown-linux-gnu/release/MedicalRegistry .
#COPY --from=builder /app/.build/x86_64-unknown-linux/release/MedicalRegistry .
#COPY --from=builder /app/.build/x86_64-apple-macosx/release/MedicalRegistry .
COPY Sources/PublicResources /app/PublicResources
COPY Sources/AppResources /app/AppResources
CMD ["./MedicalRegistry"]
