// Presentation durations are separate from a notification client's lifetime.
const defaults = {"low": 7000, "normal": 7000, "critical": 7000, "fileSaved": 7000, "volume": 2000, "microphone": 2000, "brightness": 2000, "capslock": 2000, "numlock": 2000};

function normalized(input) {
    const result = {};
    for (const key of Object.keys(defaults)) {
        const value = input && input[key];
        const number = Number(value);
        result[key] = value === null || value === undefined || value === "" || !isFinite(number)
            ? defaults[key] : Math.max(500, Math.min(60000, Math.round(number)));
    }
    return result;
}

function duration(settings, kind) {
    const values = normalized(settings);
    return values[kind] === undefined ? values.normal : values[kind];
}

function nativeTimeout(requested, fallback) {
    if (requested === 0)
        return 0;
    if (!isFinite(requested) || requested < 0)
        return fallback;
    return Math.max(1, Math.round(requested));
}

function presentationTimeout(configured, nativeLifetime) {
    return nativeLifetime > 0 ? Math.min(configured, nativeLifetime) : configured;
}
