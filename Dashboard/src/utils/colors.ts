/**
 * Port of Flutter's color interpolation logic for Page Progress recency.
 */

// Helper to interpolate between two hex colors (e.g. #2196f3 and #fbc02d)
function lerpColor(c1: string, c2: string, ratio: number): string {
    const hexToRgb = (hex: string) => {
        const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16)
        } : { r: 0, g: 0, b: 0 };
    };

    const rgb1 = hexToRgb(c1);
    const rgb2 = hexToRgb(c2);

    const r = Math.round(rgb1.r + (rgb2.r - rgb1.r) * ratio);
    const g = Math.round(rgb1.g + (rgb2.g - rgb1.g) * ratio);
    const b = Math.round(rgb1.b + (rgb2.b - rgb1.b) * ratio);

    const rgbToHex = (r: number, g: number, b: number) => 
        "#" + [r, g, b].map(x => {
            const hex = x.toString(16);
            return hex.length === 1 ? "0" + hex : hex;
        }).join("");

    return rgbToHex(r, g, b);
}

export function getPageColor(reviewDateStr?: string | null): string {
    if (!reviewDateStr) return '#e0e0e0'; // Colors.grey.shade300 (Not memorized / no review)

    const reviewDate = new Date(reviewDateStr);
    const now = new Date();
    
    // Difference in days
    const diffTime = Math.abs(now.getTime() - reviewDate.getTime());
    const daysSince = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    // clamp ratio to 0.0 - 1.0
    const ratio = Math.min(Math.max(daysSince / 7, 0.0), 1.0);

    const pureBlue = '#2196f3'; // Colors.blue
    const yellow700 = '#fbc02d'; // Colors.yellow.shade700

    return lerpColor(pureBlue, yellow700, ratio);
}
