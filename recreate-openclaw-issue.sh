#!/bin/bash

# Script to recreate OpenClaw issue every 3 hours
# Keeps OpenClaw community informed about instant access to latest models (Qwen3.5, GLM-5, MiniMax M2.5, etc.)
# Higress integration enables same-day model support without waiting for official releases

REPO="openclaw/openclaw"
TITLE="Access Qwen3.5 & Latest Models Same-Day via Higress | OpenClaw 当天接入 Qwen3.5 等最新模型（Higress 集成）"
BODY_FILE="/root/clawd/tech-blog/openclaw-higress-qwen3.5-issue-template.md"
ISSUE_NUMBER_FILE="/root/clawd/tech-blog/.last-issue-number"
LOG_FILE="/root/clawd/tech-blog/issue-recreate.log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to close old issue and create new one
recreate_issue() {
    log "Starting issue recreation..."
    
    # Read the last issue number if it exists
    if [ -f "$ISSUE_NUMBER_FILE" ]; then
        LAST_ISSUE=$(cat "$ISSUE_NUMBER_FILE")
        log "Closing previous issue #$LAST_ISSUE..."
        gh issue close "$LAST_ISSUE" --repo "$REPO" --comment "Recreating this issue to keep it fresh. New issue coming soon." 2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Create new issue
    log "Creating new issue..."
    NEW_ISSUE_URL=$(gh issue create \
        --repo "$REPO" \
        --title "$TITLE" \
        --body-file "$BODY_FILE" 2>&1)
    
    # Extract issue number from URL
    NEW_ISSUE_NUMBER=$(echo "$NEW_ISSUE_URL" | grep -oP '\d+$')
    
    # Save the new issue number
    echo "$NEW_ISSUE_NUMBER" > "$ISSUE_NUMBER_FILE"
    
    log "Created new issue: $NEW_ISSUE_URL"
    log "Issue number: $NEW_ISSUE_NUMBER"
}

# Main loop - run every 3 hours
while true; do
    recreate_issue
    log "Waiting 3 hours before next recreation..."
    sleep 10800  # 3 hours in seconds
done
