package com.impactsiswa.util;

import java.nio.file.Path;
import java.nio.file.Paths;

public final class UploadStorage {
    private UploadStorage() {
    }

    public static Path proofDirectory() {
        return uploadRoot().resolve("hour-proofs");
    }

    public static Path eventDirectory() {
        return uploadRoot().resolve("event-images");
    }

    private static Path uploadRoot() {
        String configuredRoot = System.getenv("IMPACT_UPLOAD_DIR");
        return configuredRoot == null || configuredRoot.isBlank()
                ? Paths.get(System.getProperty("user.dir"), "uploads")
                : Paths.get(configuredRoot);
    }
}
