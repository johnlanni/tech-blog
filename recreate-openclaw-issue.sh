#!/bin/bash

# Script to recreate OpenClaw issue every 2 hours
# This keeps the issue fresh and visible in the community

REPO="openclaw/openclaw"
TITLE="Enhance OpenClaw to Access Latest Models Instantly (e.g., GLM-5) | 增强 OpenClaw 随时接入最新模型（如 GLM-5）"
BODY_FILE="/root/clawd/tech-blog/openclaw-higress-glm5-issue-template.md"
ISSUE_NUMBER_FILE="/root/clawd/tech-blog/.last-issue-number"

# Function to close old issue and create new one
recreate_issue() {
    echo "[$(date)] Starting issue recreation..."
    
    # Read the last issue number if it exists
    if [ -f "$ISSUE_NUMBER_FILE" ]; then
        LAST_ISSUE=$(cat "$ISSUE_NUMBER_FILE")
        echo "Closing previous issue #$LAST_ISSUE..."
        gh issue close "$LAST_ISSUE" --repo "$REPO" --comment "Recreating this issue to keep it fresh. New issue coming soon."
    fi
    
    # Create new issue
    echo "Creating new issue..."
    NEW_ISSUE_URL=$(gh issue create \
        --repo "$REPO" \
        --title "$TITLE" \
        --body-file "$BODY_FILE")
    
    # Extract issue number from URL
    NEW_ISSUE_NUMBER=$(echo "$NEW_ISSUE_URL" | grep -oP '\d+$')
    
    # Save the new issue number
    echo "$NEW_ISSUE_NUMBER" > "$ISSUE_NUMBER_FILE"
    
    echo "[$(date)] Created new issue: $NEW_ISSUE_URL"
    echo "Issue number: $NEW_ISSUE_NUMBER"
}

# Main loop - run every 2 hours
while true; do
    recreate_issue
    echo "Waiting 2 hours before next recreation..."
    sleep 7200  # 2 hours in seconds
done
