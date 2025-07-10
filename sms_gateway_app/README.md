# Flutter SMS Gateway Mobile App

A Flutter-based mobile application that allows users to send SMS messages via a primary API and subsequently notifies a user-configured webhook with the details of the sent SMS.

## Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Configuration](#configuration)
  - [Primary SMS API Endpoint](#primary-sms-api-endpoint)
  - [Webhook Configuration](#webhook-configuration)
- [Running the App](#running-the-app)
- [How it Works](#how-it-works)
  - [Sending SMS](#sending-sms)
  - [Webhook Notification](#webhook-notification)

## Features

-   **Send SMS:** Compose and send SMS messages to recipients.
-   **API Integration:** Sends SMS messages by making a POST request to a configurable primary API endpoint.
-   **Webhook Configuration:** Allows users to set up their own webhook endpoint (URL, HTTP method, custom headers) within the app.
-   **Webhook Notification:** After an SMS is successfully sent via the primary API, the app makes a secondary HTTP request to the user-configured webhook with details of the sent SMS (recipient, body, timestamp).
-   **Cross-Platform:** Built with Flutter for iOS and Android.
-   **User Interface:**
    -   Screen for composing SMS.
    -   Screen for configuring webhook settings.
    -   Bottom navigation for easy switching between screens.
    -   Loading indicators and feedback messages (SnackBars) for user actions.
-   **Local Storage:** Webhook configurations are saved locally on the device using `shared_preferences`.

## Project Structure

```
sms_gateway_app/
├── lib/
│   ├── main.dart                 # Main application entry point, navigation
│   ├── models/                   # Data models
│   │   ├── sms_message.dart      # Model for SMS messages
│   │   └── webhook_config.dart   # Model for webhook configuration
│   ├── screens/                  # UI Screens (Widgets)
│   │   ├── compose_sms_screen.dart # UI for sending SMS
│   │   └── webhook_config_screen.dart # UI for webhook settings
│   └── services/                 # Service classes
│       ├── api_service.dart      # Handles API calls for sending SMS & notifying webhook
│       └── webhook_config_service.dart # Manages saving/loading webhook config
├── pubspec.yaml                # Project dependencies and metadata
└── README.md                   # This file
```

## Setup Instructions

### Prerequisites

-   **Flutter SDK:** Ensure you have Flutter installed. For installation instructions, see the [official Flutter documentation](https://flutter.dev/docs/get-started/install).
-   **Dart SDK:** Comes bundled with Flutter.
-   **IDE:** An IDE like Android Studio (with Flutter plugin) or Visual Studio Code (with Flutter extension).
-   **Emulator/Device:** An Android Emulator, iOS Simulator (macOS only), or a physical device set up for development.

### Installation

1.  **Clone the repository (if applicable) or download the source code.**
    ```bash
    # Example: git clone <repository-url>
    # cd sms_gateway_app
    ```
2.  **Get dependencies:**
    Open your terminal in the `sms_gateway_app` project root directory and run:
    ```bash
    flutter pub get
    ```

## Configuration

### Primary SMS API Endpoint

The application uses a mock API endpoint for sending SMS messages. You need to configure this in the `lib/services/api_service.dart` file:

1.  Open `lib/services/api_service.dart`.
2.  Locate the following constants:
    ```dart
    // TODO: Replace with your actual primary SMS sending API endpoint
    static const String _primaryApiEndpoint = 'https://api.example.com/send_sms';
    // TODO: Replace with your actual API key or token for the primary API
    static const String _primaryApiKey = 'YOUR_PRIMARY_API_KEY';
    ```
3.  **Modify `_primaryApiEndpoint`**: Change this URL to your actual SMS sending API endpoint if you have one. For testing, you can use a mock server like [Beeceptor](https://beeceptor.com/) or [Mockoon](https://mockoon.com/) to simulate responses.
4.  **Modify `_primaryApiKey`**: Update this with your actual API key. The current implementation sends this key in an `X-Api-Key` header. Adjust the headers in `ApiService.sendSmsAndNotifyWebhook` method if your API requires a different authentication mechanism (e.g., Bearer token in 'Authorization' header).

**Example Mock API Behavior:**
The app expects the primary API to return a `200` or `201` status code for a successful SMS send.

### Webhook Configuration

The webhook to be notified after an SMS is sent is configured *within the app itself* by the user:

1.  Run the app.
2.  Navigate to the "Webhook Cfg" tab using the bottom navigation bar.
3.  **URL:** Enter the full URL of your webhook endpoint that can receive POST requests (or the method you select).
4.  **HTTP Method:** Select the HTTP method your webhook endpoint expects (default is POST).
5.  **Custom Headers:** Add any custom headers your webhook endpoint requires (e.g., for authentication).
6.  Click "Save Configuration".

## Running the App

1.  Ensure you have an emulator running or a device connected.
2.  Open your terminal in the `sms_gateway_app` project root directory.
3.  Run the app:
    ```bash
    flutter run
    ```

## How it Works

### Sending SMS

1.  The user navigates to the "Send SMS" screen.
2.  They enter the recipient's phone number and the message body.
3.  Upon clicking "Send SMS & Notify Webhook":
    a.  The app first makes an HTTP POST request to the `_primaryApiEndpoint` (configured in `api_service.dart`) with the SMS details (recipient, body) and authentication headers.
    b.  The app displays a success or failure message based on the API response.

### Webhook Notification

1.  **If the primary SMS send is successful (step 3b above):**
    a.  The app retrieves the webhook configuration (URL, method, headers) saved by the user from local storage.
    b.  If a valid webhook URL is configured, the app constructs a JSON payload containing:
        ```json
        {
          "sent_to": "recipient_phone_number",
          "body": "sms_message_body",
          "timestamp": "ISO_8601_timestamp",
          "status": "sent"
        }
        ```
    c.  The app then makes an HTTP request (e.g., POST, or the method specified by the user) to the user's configured webhook URL with this payload and the configured custom headers.
    d.  The app logs the success or failure of this webhook notification attempt to the console but the overall success message to the user primarily reflects the status of the initial SMS send.
2.  **If the primary SMS send fails, or if no valid webhook is configured, the webhook notification step is skipped.**

This allows users to integrate the SMS sending functionality with their own backend services by having their service listen for these webhook notifications.
