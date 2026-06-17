package com.impactsiswa.util;

import java.nio.file.Path;
import java.nio.file.Paths;

public final class UploadStorage {
    private UploadStorage() {
    }

    public static Path proofDirectory() {
        String configuredRoot = System.getenv("IMPACT_UPLOAD_DIR");
        Path root = configuredRoot == null || configuredRoot.isBlank()
                ? Paths.get(System.getProperty("user.dir"), "uploads")
                : Paths.get(configuredRoot);
        return root.resolve("hour-proofs");
    }
}
