const mongoose = require('mongoose');
require('dotenv').config();
const { Campaign, EmailEvent, TrackedLink } = require('./models/trackingModels');

async function checkDb() {
    try {
        const MONGODB_URI = process.env.MONGODB_URI;
        console.log('Connecting to:', MONGODB_URI);
        await mongoose.connect(MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        const campaignCount = await Campaign.countDocuments();
        console.log('Total Campaigns:', campaignCount);

        const latestCampaign = await Campaign.findOne().sort({ createdAt: -1 });
        if (latestCampaign) {
            console.log('Latest Campaign:', {
                id: latestCampaign._id,
                subject: latestCampaign.subject,
                sent: latestCampaign.sentCount,
                opened: latestCampaign.openedCount,
                clicked: latestCampaign.clickedCount,
                status: latestCampaign.status,
                createdAt: latestCampaign.createdAt
            });
            console.log('Template Snippet:', latestCampaign.template.substring(0, 100));
            const hasLinks = /href=/i.test(latestCampaign.template);
            console.log('Template has href:', hasLinks);

            const eventCount = await EmailEvent.countDocuments({ campaignId: latestCampaign._id });
            console.log(`Events for this campaign: ${eventCount}`);

            const newestEvent = await EmailEvent.findOne({ campaignId: latestCampaign._id }).sort({ createdAt: -1 });
            if (newestEvent) {
                console.log('Newest Event:', {
                    email: newestEvent.recipientEmail,
                    status: newestEvent.status,
                    trackingId: newestEvent.trackingId,
                    opens: newestEvent.openCount,
                    clicks: newestEvent.clickCount,
                    eventsCount: newestEvent.events.length
                });
                console.log('Event Timeline:', newestEvent.events);
            }

            const linkCount = await TrackedLink.countDocuments({ campaignId: latestCampaign._id });
            console.log(`Tracked Links for this campaign: ${linkCount}`);
        } else {
            console.log('❌ No campaigns found');
        }

        process.exit(0);
    } catch (err) {
        console.error('❌ Error:', err);
        process.exit(1);
    }
}

checkDb();
