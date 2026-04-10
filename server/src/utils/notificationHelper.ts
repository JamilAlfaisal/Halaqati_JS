// src/utils/notificationHelper.ts
import * as admin from 'firebase-admin';
import * as path from 'path';

interface NotificationPayload {
    title: string;
    body: string;
    tokens: string[];
    data?: { [key: string]: string };
}

export const sendNotification = async ({ title, body, tokens, data }: NotificationPayload) => {
    if (!tokens || tokens.length === 0) return;

    const message: admin.messaging.MulticastMessage = {
        tokens,
        notification: {
            title: title,
            body: body,
        },
        data: {
            title: title,
            body: body,
            assignmentId: data?.assignmentId ?? "0",
            classId: data?.classId ?? "0",
            type: data?.type ?? "",
        },
    };

    try {
        const response = await admin.messaging().sendEachForMulticast(message);
        console.log(`✅ Notifications sent: ${response.successCount}/${tokens.length}`);
        if (response.failureCount > 0) {
            console.warn(response.responses.filter(r => !r.success));
        }
    } catch (error) {
        console.error("❌ Failed to send notifications:", error);
    }
};