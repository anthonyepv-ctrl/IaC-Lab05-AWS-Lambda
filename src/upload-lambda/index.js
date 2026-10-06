const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const { v4: uuidv4 } = require("uuid");
const busboy = require("busboy");

const s3 = new S3Client({});
const BUCKET = process.env.S3_BUCKET;
const PREFIX = process.env.UPLOAD_PREFIX || "uploads/";
const MAX_BYTES = 10 * 1024 * 1024;
const ALLOWED = ["image/jpeg", "image/png", "image/gif", "image/webp"];

const reply = (statusCode, body) => ({
    statusCode,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
});

const parseMultipart = (body, contentType) =>
    new Promise((resolve, reject) => {
        let fileBuffer, fileName, mime;
        const bb = busboy({ headers: { "content-type": contentType } });
        bb.on("file", (_n, file, info) => {
            mime = info.mimeType;
            fileName = info.filename;
            const chunks = [];
            file.on("data", (c) => chunks.push(c));
            file.on("end", () => { fileBuffer = Buffer.concat(chunks); });
        });
        bb.on("close", () => resolve({ fileBuffer, fileName, mime }));
        bb.on("error", reject);
        bb.end(body);
    });

exports.handler = async (event) => {
    try {
        const headers = event.headers || {};
        const contentType = headers["content-type"] || headers["Content-Type"] || "";
        const raw = Buffer.from(event.body || "", event.isBase64Encoded ? "base64" : "utf8");

        let fileBuffer, fileName, mime;

        if (contentType.includes("multipart/form-data")) {
            ({ fileBuffer, fileName, mime } = await parseMultipart(raw, contentType));
        } else if (contentType.includes("application/json")) {
            const payload = JSON.parse(raw.toString("utf8"));
            if (payload.data) fileBuffer = Buffer.from(payload.data, "base64");
            fileName = payload.filename;
            mime = payload.contentType;
        } else {
            return reply(400, { message: "Use multipart/form-data or JSON with base64" });
        }

        if (!fileBuffer || fileBuffer.length === 0) return reply(400, { message: "No file uploaded" });
        if (fileBuffer.length > MAX_BYTES) return reply(400, { message: "File too large. Max 10 MB" });
        if (!ALLOWED.includes(mime)) return reply(400, { message: "Invalid format. Allowed: jpg, png, gif, webp" });

        const ext = (fileName || "img.jpg").split(".").pop();
        const key = PREFIX + uuidv4() + "." + ext;

        await s3.send(new PutObjectCommand({ Bucket: BUCKET, Key: key, Body: fileBuffer, ContentType: mime }));
        return reply(201, { message: "Uploaded", key });
    } catch (err) {
        console.error("Error en upload-lambda:", err);
        return reply(500, { message: "Internal Server Error" });
    }
};