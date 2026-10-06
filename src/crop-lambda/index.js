const { S3Client, GetObjectCommand, PutObjectCommand } = require("@aws-sdk/client-s3");
const sharp = require("sharp");

const s3 = new S3Client({});
const DEST = process.env.PROCESSED_PREFIX || "processed/";
const SIZE = 40;
const MASK = Buffer.from(
    `<svg width="${SIZE}" height="${SIZE}"><circle cx="${SIZE / 2}" cy="${SIZE / 2}" r="${SIZE / 2}" fill="#fff"/></svg>`
);

exports.handler = async (event) => {
    const batchItemFailures = [];

    for (const sqsRecord of event.Records) {
        try {
            const s3Event = JSON.parse(sqsRecord.body);
            if (!s3Event.Records) continue;

            for (const rec of s3Event.Records) {
                const bucket = rec.s3.bucket.name;
                const key = decodeURIComponent(rec.s3.object.key.replace(/\+/g, " "));

                const obj = await s3.send(new GetObjectCommand({ Bucket: bucket, Key: key }));
                const input = Buffer.from(await obj.Body.transformToByteArray());

                const out = await sharp(input)
                    .resize(SIZE, SIZE, { fit: "cover" })
                    .ensureAlpha()
                    .composite([{ input: MASK, blend: "dest-in" }])
                    .png()
                    .toBuffer();

                const name = key.split("/").pop().replace(/\.[^.]+$/, "") + "_circular.png";
                await s3.send(new PutObjectCommand({
                    Bucket: bucket,
                    Key: DEST + name,
                    Body: out,
                    ContentType: "image/png",
                }));
            }
        } catch (err) {
            console.error("Error procesando mensaje", sqsRecord.messageId, err);
            batchItemFailures.push({ itemIdentifier: sqsRecord.messageId });
        }
    }

    return { batchItemFailures };
};