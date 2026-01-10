const mongoose = require('mongoose');

// Campaign Schema - Stores email campaign metadata and statistics
const campaignSchema = new mongoose.Schema({
  subject: {
    type: String,
    required: true
  },
  template: {
    type: String,
    required: true
  },
  senderEmail: {
    type: String,
    required: true
  },
  senderName: {
    type: String,
    default: ''
  },
  totalEmails: {
    type: Number,
    default: 0
  },
  sentCount: {
    type: Number,
    default: 0
  },
  deliveredCount: {
    type: Number,
    default: 0
  },
  openedCount: {
    type: Number,
    default: 0
  },
  clickedCount: {
    type: Number,
    default: 0
  },
  failedCount: {
    type: Number,
    default: 0
  },
  bouncedCount: {
    type: Number,
    default: 0
  },
  status: {
    type: String,
    enum: ['pending', 'sending', 'completed', 'failed'],
    default: 'pending'
  },
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  completedAt: {
    type: Date
  },
  userId: {
    type: String,
    required: true,
    index: true
  }
}, {
  timestamps: true
});

// Indexes for faster lookups
campaignSchema.index({ userId: 1, createdAt: -1 });

// Virtual fields for calculated statistics
campaignSchema.virtual('openRate').get(function () {
  if (this.deliveredCount === 0) return 0;
  return ((this.openedCount / this.deliveredCount) * 100).toFixed(2);
});

campaignSchema.virtual('clickRate').get(function () {
  if (this.deliveredCount === 0) return 0;
  return ((this.clickedCount / this.deliveredCount) * 100).toFixed(2);
});

campaignSchema.virtual('deliveryRate').get(function () {
  if (this.totalEmails === 0) return 0;
  return ((this.deliveredCount / this.totalEmails) * 100).toFixed(2);
});

campaignSchema.virtual('failureRate').get(function () {
  if (this.totalEmails === 0) return 0;
  return ((this.failedCount / this.totalEmails) * 100).toFixed(2);
});

// Ensure virtuals are included in JSON
campaignSchema.set('toJSON', { virtuals: true });
campaignSchema.set('toObject', { virtuals: true });

// Email Event Schema - Stores individual email events
const emailEventSchema = new mongoose.Schema({
  campaignId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Campaign',
    required: true,
    index: true
  },
  trackingId: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  recipientEmail: {
    type: String,
    required: true
  },
  recipientName: {
    type: String,
    default: ''
  },
  status: {
    type: String,
    enum: ['sent', 'delivered', 'opened', 'clicked', 'bounced', 'failed'],
    default: 'sent'
  },
  events: [{
    type: {
      type: String,
      enum: ['sent', 'delivered', 'opened', 'clicked', 'bounced', 'failed']
    },
    timestamp: {
      type: Date,
      default: Date.now
    },
    metadata: {
      type: mongoose.Schema.Types.Mixed
    }
  }],
  openCount: {
    type: Number,
    default: 0
  },
  clickCount: {
    type: Number,
    default: 0
  },
  firstOpenedAt: {
    type: Date
  },
  lastOpenedAt: {
    type: Date
  },
  metadata: {
    userAgent: String,
    ipAddress: String,
    location: String,
    device: String,
    clickedLinks: [{
      url: String,
      timestamp: Date
    }]
  },
  errorMessage: {
    type: String
  }
}, {
  timestamps: true
});

// Indexes for better query performance
emailEventSchema.index({ campaignId: 1, status: 1 });
emailEventSchema.index({ recipientEmail: 1 });
emailEventSchema.index({ createdAt: -1 });

// Tracked Link Schema - Maps short tracking URLs to original URLs
const trackedLinkSchema = new mongoose.Schema({
  linkId: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  campaignId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Campaign',
    required: true
  },
  emailTrackingId: {
    type: String,
    required: true,
    index: true
  },
  originalUrl: {
    type: String,
    required: true
  },
  clickCount: {
    type: Number,
    default: 0
  },
  clicks: [{
    timestamp: {
      type: Date,
      default: Date.now
    },
    userAgent: String,
    ipAddress: String,
    location: String,
    device: String
  }]
}, {
  timestamps: true
});

// Indexes
trackedLinkSchema.index({ campaignId: 1 });
trackedLinkSchema.index({ emailTrackingId: 1 });

// Create models
const Campaign = mongoose.model('Campaign', campaignSchema);
const EmailEvent = mongoose.model('EmailEvent', emailEventSchema);
const TrackedLink = mongoose.model('TrackedLink', trackedLinkSchema);

module.exports = {
  Campaign,
  EmailEvent,
  TrackedLink
};
