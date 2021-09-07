## Extending Channels with Integrations

Settings for integrations are accessible from the **Main Menu** by clicking the three dots at the top of the channels pane. Clicking **Integrations** opens a page where you can view and configure incoming webhooks, outgoing webhooks, and slash commands for your team. If you can't see an **Integrations** option, then your System Admin may have only given Admins access.

[Visit our app directory](https://about.mattermost.com/default-app-directory/) for dozens of open source integrations to common tools like Jira, Jenkins, GitLab, Trac, Redmine, and Bitbucket, along with interactive bot applications (Hubot, mattermost-bot), and other communication tools (Email, IRC, XMPP, Threema) that are freely available for use and customization.

## Incoming Webhooks

Incoming webhooks from external integrations can post messages to Mattermost in public and private channels. Learn more about setting up incoming webhooks in our [developer documentation](https://developers.mattermost.com/integrate/other-integrations/incoming-webhooks/).

## Outgoing Webhooks

Outgoing webhooks use trigger words to fire new message events to external integrations. For security reasons, outgoing webhooks are only available in public channels. Learn more about setting up outgoing webhooks in our [developer documentation](https://developers.mattermost.com/integrate/other-integrations/outgoing-webhooks/).

## Slash Commands

Slash commands allow users to interact with external applications by typing `/` followed by a command. See [executing slash commands](https://docs.mattermost.com/messaging/executing-slash-commands.html) for a list of built-in commands. Learn more about setting up custom slash commands on our [developer documentation](https://developers.mattermost.com/integrate/other-integrations/slash-commands/).