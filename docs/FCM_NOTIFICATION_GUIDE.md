# FCM Notification Features Guide

This guide explains the FCM notification features available in the AirSpot Health app and how to implement them in your admin panel.

## ✅ Supported Features

### 1. **Image Notifications**

- Display large images in notifications (Android BigPicture style & iOS attachments)
- Images are downloaded from a URL and displayed

### 2. **URL Deep Linking**

- Open any URL when the notification is tapped
- Opens in external browser
- Works from all app states (foreground, background, terminated)

---

## FCM Payload Format

### Basic Notification (Text Only)

```json
{
  "notification": {
    "title": "Your Notification Title",
    "body": "Your notification message body"
  },
  "token": "USER_FCM_TOKEN"
}
```

### Notification with Image

```json
{
  "notification": {
    "title": "Check out this update!",
    "body": "We have something exciting to show you",
    "image": "https://example.com/path/to/image.jpg"
  },
  "data": {
    "image": "https://example.com/path/to/image.jpg"
  },
  "token": "USER_FCM_TOKEN",
  "android": {
    "notification": {
      "imageUrl": "https://example.com/path/to/image.jpg"
    }
  },
  "apns": {
    "payload": {
      "aps": {
        "mutable-content": 1
      }
    },
    "fcm_options": {
      "image": "https://example.com/path/to/image.jpg"
    }
  }
}
```

### Notification with URL (Click to Open)

```json
{
  "notification": {
    "title": "New Article Available",
    "body": "Tap to read the latest health tips"
  },
  "data": {
    "url": "https://airspothealth.com/articles/latest-health-tips"
  },
  "token": "USER_FCM_TOKEN"
}
```

### Notification with Both Image AND URL

```json
{
  "notification": {
    "title": "New Product Launch! 🎉",
    "body": "Check out our latest CO₂ monitor",
    "image": "https://example.com/products/co2-monitor.jpg"
  },
  "data": {
    "url": "https://shop.airspothealth.com/co2-monitor",
    "image": "https://example.com/products/co2-monitor.jpg"
  },
  "token": "USER_FCM_TOKEN",
  "android": {
    "notification": {
      "imageUrl": "https://example.com/products/co2-monitor.jpg"
    }
  },
  "apns": {
    "payload": {
      "aps": {
        "mutable-content": 1
      }
    },
    "fcm_options": {
      "image": "https://example.com/products/co2-monitor.jpg"
    }
  }
}
```

---

## Admin Panel Implementation Guide

### Required Fields in Admin Panel

#### 1. Basic Fields (Required)

```javascript
{
  title: string,          // Notification title
  body: string,           // Notification body text
  targetUsers: string[]   // Array of FCM tokens
}
```

#### 2. Optional Fields

```javascript
{
  imageUrl: string,       // URL to notification image (JPEG, PNG, WebP)
  clickUrl: string        // URL to open when notification is clicked
}
```

### Image Requirements

- **Supported Formats**: JPEG, PNG, WebP
- **Recommended Size**:
  - Android: 1200 x 628 px (16:9 aspect ratio)
  - iOS: 1200 x 600 px
- **Max File Size**: < 1 MB (for faster loading)
- **URL Requirements**:
  - Must be publicly accessible (HTTPS)
  - No authentication required
  - Must have proper CORS headers

### URL Requirements

- **Valid URL Format**: Must start with `http://` or `https://`
- **Examples**:
  - Website: `https://airspothealth.com`
  - Article: `https://blog.airspothealth.com/article/123`
  - Product: `https://shop.airspothealth.com/product/456`
  - External: `https://youtube.com/watch?v=xyz`

---

## Example Admin Panel UI

### Form Fields

```html
<form id="notification-form">
  <!-- Basic Fields -->
  <input type="text" name="title" placeholder="Notification Title" required />
  <textarea name="body" placeholder="Message body" required></textarea>

  <!-- Optional: Image -->
  <input type="url" name="imageUrl" placeholder="Image URL (optional)" />
  <small>Enter a public image URL (https://...)</small>

  <!-- Optional: Click Action URL -->
  <input type="url" name="clickUrl" placeholder="Click URL (optional)" />
  <small>URL to open when notification is tapped</small>

  <!-- Target Users -->
  <select name="targetUsers" multiple>
    <option value="all">All Users</option>
    <option value="topic:alerts">Alert Subscribers</option>
    <!-- User-specific tokens -->
  </select>

  <button type="submit">Send Notification</button>
</form>
```

### JavaScript Code Example

```javascript
async function sendNotification(formData) {
  const payload = {
    notification: {
      title: formData.title,
      body: formData.body,
    },
    data: {},
  };

  // Add image if provided
  if (formData.imageUrl) {
    payload.notification.image = formData.imageUrl;
    payload.data.image = formData.imageUrl;
    payload.android = {
      notification: {
        imageUrl: formData.imageUrl,
      },
    };
    payload.apns = {
      payload: {
        aps: {
          "mutable-content": 1,
        },
      },
      fcm_options: {
        image: formData.imageUrl,
      },
    };
  }

  // Add URL if provided
  if (formData.clickUrl) {
    payload.data.url = formData.clickUrl;
  }

  // Send to FCM
  const response = await fetch(
    "https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          ...payload,
          token: userFcmToken, // or use 'topic' for topic-based messaging
        },
      }),
    }
  );

  return response.json();
}
```

---

## Testing

### Test Payload Examples

#### 1. Test Image Notification

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "USER_FCM_TOKEN",
      "notification": {
        "title": "Test Image Notification",
        "body": "This notification has an image",
        "image": "https://picsum.photos/1200/628"
      },
      "data": {
        "image": "https://picsum.photos/1200/628"
      },
      "android": {
        "notification": {
          "imageUrl": "https://picsum.photos/1200/628"
        }
      }
    }
  }'
```

#### 2. Test URL Notification

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "USER_FCM_TOKEN",
      "notification": {
        "title": "Test URL Notification",
        "body": "Tap to open website"
      },
      "data": {
        "url": "https://google.com"
      }
    }
  }'
```

#### 3. Test Combined (Image + URL)

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "USER_FCM_TOKEN",
      "notification": {
        "title": "Special Offer!",
        "body": "Tap to view details",
        "image": "https://picsum.photos/1200/628"
      },
      "data": {
        "url": "https://example.com/offer",
        "image": "https://picsum.photos/1200/628"
      },
      "android": {
        "notification": {
          "imageUrl": "https://picsum.photos/1200/628"
        }
      }
    }
  }'
```

---

## Notification Behavior

### Android

- **Foreground**: Custom notification displayed with image (BigPicture style)
- **Background**: System notification with image
- **Tap Action**: Opens URL in external browser if provided

### iOS

- **Foreground**: Custom notification displayed with image attachment
- **Background**: System notification with image
- **Tap Action**: Opens URL in external browser if provided

---

## Topic-Based Messaging

You can also send to topics instead of individual tokens:

```json
{
  "notification": {
    "title": "Updates for All Users",
    "body": "Check out the latest news"
  },
  "data": {
    "url": "https://airspothealth.com/news"
  },
  "topic": "all_users"
}
```

### Available Topics

- `all_users` - All app users
- `alerts` - Users who enabled alert notifications
- `co2_alerts` - Users who enabled CO₂ notifications

---

## Troubleshooting

### Images Not Showing

1. ✅ Ensure image URL is publicly accessible (test in browser)
2. ✅ Check image format (JPEG, PNG, WebP supported)
3. ✅ Verify image size (< 1 MB recommended)
4. ✅ Ensure proper CORS headers on image server

### URL Not Opening

1. ✅ Verify URL format (must start with http:// or https://)
2. ✅ Test URL in browser first
3. ✅ Check app logs for error messages

### Notification Not Received

1. ✅ Verify FCM token is valid and current
2. ✅ Check notification permissions are granted
3. ✅ Ensure device has internet connection
4. ✅ Check FCM console for delivery status

---

## Summary

Your admin panel should support:

✅ **Basic Text Notifications** - Title and body
✅ **Image Notifications** - Add an image URL field
✅ **URL Click Actions** - Add a click URL field
✅ **Combined Features** - Both image and URL together

All features work seamlessly across Android and iOS!
