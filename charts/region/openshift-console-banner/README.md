# Banner for OpenShift console

This is a simple banner helm chart that can be used to display text in an OpenShift 
console. 

The values.yaml file contains the following attributes:

| Name | Type | Description |
| :---: | :----: | :----: |
| banner.text | string | String to display on the OpenShift console |
| banner.location | BannerTop, BannerBottom, and BannerTopBottom | Location of Notification |
| banner.environment | string | String that described Environment e.g. DEVELOPMENT |
| banner.color |  hex color code | Hex color code (#fff) or name e.g. red |
| banner.backgroundColor |  hex color code | Hex color code (#000000) or name e.g. black |

