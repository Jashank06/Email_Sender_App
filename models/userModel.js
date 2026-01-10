const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    userId: {
        type: String,
        required: true,
        unique: true,
        index: true
    },
    name: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true,
        index: true
    },
    phone: {
        type: String,
        required: true
    },
    dateOfBirth: {
        type: String,
        required: true
    },
    lastLogin: {
        type: Date,
        default: Date.now
    },
    savedEmail: {
        type: String,
        default: ''
    },
    savedPassword: {
        type: String,
        default: ''
    },
    savedProvider: {
        type: String,
        default: 'gmail'
    }
}, {
    timestamps: true
});

const User = mongoose.model('User', userSchema);

module.exports = User;
