# README
Demo App for 2-way communication with Google Calendar API.

In order to call Google Calendar APIs, you need 2 API keys ie client_id and client_secret_id.

Create a project on Google API console and get API keys in Credentials section.

These API keys are available in development.yml, which can be edited using after creating project on API console:
EDITOR='nano' rails credentials:edit --environment development

For working with Google Calendar in development environment, some prerequisites/configurations need to be done ie mentioned here(https://docs.google.com/document/d/1_qlaW49GZq1p0V13AQ6kw1cb2w5PV0ptei3ROFMsl0k/edit?usp=sharing)