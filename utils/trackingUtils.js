const { v4: uuidv4 } = require('uuid');
const geoip = require('geoip-lite');

/**
 * Generate a unique tracking ID for an email
 */
function generateTrackingId() {
    return uuidv4();
}

/**
 * Generate a short unique ID for link tracking
 */
function generateShortId() {
    return uuidv4().split('-')[0];
}

/**
 * Generate HTML for tracking pixel
 * @param {string} trackingId - Unique tracking ID for the email
 * @param {string} baseUrl - Base URL of the server
 * @returns {string} HTML string for tracking pixel
 */
function generateTrackingPixel(trackingId, baseUrl) {
    const pixelUrl = `${baseUrl}/track/open/${trackingId}`;
    return `<img src="${pixelUrl}" width="1" height="1" style="display:none;" alt="" />`;
}

/**
 * Inject tracking pixel into email HTML
 * @param {string} html - Original HTML content
 * @param {string} trackingId - Unique tracking ID
 * @param {string} baseUrl - Base URL of the server
 * @returns {string} HTML with tracking pixel injected
 */
function injectTrackingPixel(html, trackingId, baseUrl) {
    const pixel = generateTrackingPixel(trackingId, baseUrl);

    // Try to inject before closing body tag
    if (html.includes('</body>')) {
        return html.replace('</body>', `${pixel}</body>`);
    }

    // If no body tag, append at the end
    return html + pixel;
}

/**
 * Extract all links from HTML content
 * @param {string} html - HTML content
 * @returns {Array} Array of URLs found in the HTML
 */
function extractLinks(html) {
    const links = [];
    const hrefRegex = /href=["']([^"']+)["']/gi;
    let match;

    while ((match = hrefRegex.exec(html)) !== null) {
        const url = match[1];
        // Skip mailto, tel, and anchor links
        if (!url.startsWith('mailto:') && !url.startsWith('tel:') && !url.startsWith('#')) {
            links.push(url);
        }
    }

    return links;
}

/**
 * Replace all links in HTML with tracked versions
 * @param {string} html - Original HTML content
 * @param {string} emailTrackingId - Tracking ID for the email
 * @param {string} baseUrl - Base URL of the server
 * @param {Function} linkIdGenerator - Function to generate link IDs
 * @returns {Object} Object with modified HTML and link mappings
 */
function replaceLinksWithTracking(html, emailTrackingId, baseUrl, linkIdGenerator) {
    const linkMappings = [];
    let modifiedHtml = html;

    const hrefRegex = /href=(["'])([^"']+)\1/gi;
    const matches = [...html.matchAll(hrefRegex)];

    // We need to track which originalUrls we've processed to avoid double-replacing
    // if the same URL appears multiple times, we replace them one by one.
    // However, the previous implementation was actually clever about this.
    // Let's use a more precise replacement that accounts for the quotes.

    for (const match of matches) {
        const quote = match[1];
        const originalUrl = match[2];

        // Skip mailto, tel, and anchor links
        if (originalUrl.startsWith('mailto:') || originalUrl.startsWith('tel:') || originalUrl.startsWith('#')) {
            continue;
        }

        // Generate unique link ID
        const linkId = linkIdGenerator();
        const trackedUrl = `${baseUrl}/track/click/${linkId}`;

        // Replace only the NEXT occurrence of this specific href attribute
        const searchPattern = `href=${quote}${originalUrl}${quote}`;
        const replacement = `href=${quote}${trackedUrl}${quote}`;

        if (modifiedHtml.includes(searchPattern)) {
            // String.replace(string, string) replaces only the first occurrence
            modifiedHtml = modifiedHtml.replace(searchPattern, replacement);

            linkMappings.push({
                linkId,
                originalUrl,
                emailTrackingId
            });
        }
    }

    return {
        html: modifiedHtml,
        linkMappings
    };
}

/**
 * Parse user agent string to extract device information
 * @param {string} userAgent - User agent string
 * @returns {Object} Parsed device information
 */
function parseUserAgent(userAgent) {
    if (!userAgent) {
        return {
            device: 'Unknown',
            browser: 'Unknown',
            os: 'Unknown'
        };
    }

    const ua = userAgent.toLowerCase();

    // Detect device type
    let device = 'Desktop';
    if (/(tablet|ipad|playbook|silk)|(android(?!.*mobi))/i.test(userAgent)) {
        device = 'Tablet';
    } else if (/Mobile|Android|iP(hone|od)|IEMobile|BlackBerry|Kindle|Silk-Accelerated|(hpw|web)OS|Opera M(obi|ini)/.test(userAgent)) {
        device = 'Mobile';
    }

    // Detect browser
    let browser = 'Unknown';
    if (ua.includes('firefox')) browser = 'Firefox';
    else if (ua.includes('chrome')) browser = 'Chrome';
    else if (ua.includes('safari')) browser = 'Safari';
    else if (ua.includes('edge')) browser = 'Edge';
    else if (ua.includes('opera') || ua.includes('opr')) browser = 'Opera';
    else if (ua.includes('msie') || ua.includes('trident')) browser = 'Internet Explorer';

    // Detect OS
    let os = 'Unknown';
    if (ua.includes('windows')) os = 'Windows';
    else if (ua.includes('mac')) os = 'macOS';
    else if (ua.includes('linux')) os = 'Linux';
    else if (ua.includes('android')) os = 'Android';
    else if (ua.includes('ios') || ua.includes('iphone') || ua.includes('ipad')) os = 'iOS';

    return { device, browser, os };
}

/**
 * Get location from IP address
 * @param {string} ipAddress - IP address
 * @returns {Object} Location information
 */
function getLocationFromIP(ipAddress) {
    if (!ipAddress || ipAddress === '::1' || ipAddress === '127.0.0.1') {
        return {
            country: 'Unknown',
            city: 'Unknown',
            region: 'Unknown'
        };
    }

    const geo = geoip.lookup(ipAddress);

    if (!geo) {
        return {
            country: 'Unknown',
            city: 'Unknown',
            region: 'Unknown'
        };
    }

    return {
        country: geo.country || 'Unknown',
        city: geo.city || 'Unknown',
        region: geo.region || 'Unknown',
        timezone: geo.timezone || 'Unknown'
    };
}

/**
 * Extract client IP address from request
 * @param {Object} req - Express request object
 * @returns {string} IP address
 */
function getClientIP(req) {
    return req.headers['x-forwarded-for']?.split(',')[0] ||
        req.headers['x-real-ip'] ||
        req.connection?.remoteAddress ||
        req.socket?.remoteAddress ||
        req.ip ||
        'Unknown';
}

/**
 * Calculate email sending statistics
 * @param {Object} campaign - Campaign object
 * @returns {Object} Statistics object
 */
function calculateStats(campaign) {
    const total = campaign.totalEmails || 0;
    const sent = campaign.sentCount || 0;
    const delivered = campaign.deliveredCount || 0;
    const opened = campaign.openedCount || 0;
    const clicked = campaign.clickedCount || 0;
    const failed = campaign.failedCount || 0;

    return {
        total,
        sent,
        delivered,
        opened,
        clicked,
        failed,
        openRate: delivered > 0 ? ((opened / delivered) * 100).toFixed(2) : 0,
        clickRate: delivered > 0 ? ((clicked / delivered) * 100).toFixed(2) : 0,
        deliveryRate: total > 0 ? ((delivered / total) * 100).toFixed(2) : 0,
        failureRate: total > 0 ? ((failed / total) * 100).toFixed(2) : 0
    };
}

module.exports = {
    generateTrackingId,
    generateShortId,
    generateTrackingPixel,
    injectTrackingPixel,
    extractLinks,
    replaceLinksWithTracking,
    parseUserAgent,
    getLocationFromIP,
    getClientIP,
    calculateStats
};
