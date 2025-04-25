package com.dexterous.flutterlocalnotifications;

import android.app.Notification;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import androidx.annotation.RequiresApi;

/**
 * Helper class to fix the ambiguous bigLargeIcon method issue in BigPictureStyle
 */
public class BigPictureStyleFix {
    
    /**
     * Apply the BigPictureStyle to a notification builder with a safe implementation
     * that avoids the ambiguous method call
     */
    public static void applyBigPictureStyle(Notification.Builder builder, 
                                           Bitmap bigPicture, 
                                           Bitmap largeIcon,
                                           String contentTitle,
                                           String summaryText,
                                           boolean hideExpandedLargeIcon) {
        
        Notification.BigPictureStyle bigPictureStyle = new Notification.BigPictureStyle();
        bigPictureStyle.bigPicture(bigPicture);
        
        if (contentTitle != null) {
            bigPictureStyle.setBigContentTitle(contentTitle);
        }
        
        if (summaryText != null) {
            bigPictureStyle.setSummaryText(summaryText);
        }
        
        // This is the problematic line that we're fixing
        // Instead of calling bigLargeIcon(null) which is ambiguous,
        // we'll use a specific implementation based on the Android version
        if (hideExpandedLargeIcon) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                // For Android 6.0+ (API level 23+), we'll use the Icon version
                applyNullBigLargeIconForM(bigPictureStyle);
            } else {
                // For older versions, we'll use the Bitmap version
                bigPictureStyle.bigLargeIcon((Bitmap) null);
            }
        } else if (largeIcon != null) {
            bigPictureStyle.bigLargeIcon(largeIcon);
        }
        
        builder.setStyle(bigPictureStyle);
    }
    
    @RequiresApi(api = Build.VERSION_CODES.M)
    private static void applyNullBigLargeIconForM(Notification.BigPictureStyle bigPictureStyle) {
        // On Android 6.0+, we'll use a transparent 1x1 bitmap instead of null
        // This avoids the ambiguity between bigLargeIcon(Bitmap) and bigLargeIcon(Icon)
        Bitmap transparentBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888);
        bigPictureStyle.bigLargeIcon(transparentBitmap);
    }
}
