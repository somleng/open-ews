# OpenEWS

The world's first Open Source Emergency Warning System Dissemination Dashboard

![Build](https://github.com/somleng/open-ews/workflows/Build/badge.svg)
[![View performance data on Skylight](https://badges.skylight.io/status/YxPzpqwXsqPx.svg)](https://oss.skylight.io/app/applications/YxPzpqwXsqPx)

![somleng-ews-dissemination-dashboard-drawing](https://github.com/user-attachments/assets/cfcb0480-dbaa-48b4-91c1-3b24af3ca985)

The [EWS4All](https://www.un.org/en/climatechange/early-warnings-for-all) initiative calls for:

> Every person on Earth to be protected by early warning systems within by 2027.

We will help to achieve this goal building and [certifying](https://www.digitalpublicgoods.net/submission-guide) OpenEWS - the world's first Open Source Emergency Warning System Dissemination Dashboard.

OpenEWS is intended to be used by Governments and/or NGOs acting on behalf of Governments to disseminate warning messages to beneficiaries in case of a natural disaster or other public health emergency.

OpenEWS is:

* 👯‍♀️ Aesthetically Beautiful
* 🧘 Easy to use
* ញ Localizable
* 🛜 Interoperable
* 💖 Free and Open Source
* ✅ DPG Certified

## OpenEWS + Somleng

In order to deliver the emergency warning messages to the beneficiaries OpenEWS will connect to Somleng out of the box. [Somleng](https://github.com/somleng/somleng) (Part of the Somleng Project) is an Open Source, [DPG Certified](https://www.digitalpublicgoods.net/registry#:~:text=Somleng), Telco-as-a-Service (TaaS) and Communications-Platform-as-a-Service (CPaaS).

Local Mobile Network Operators (MNOs) can use Somleng to deliver EWS messages to beneficiaries on their networks via the following channels.

* 📲 Voice Alerts (IVR)
* 💬 SMS
* 🗼 Cell Broadcast

## Deployment

The [infrastructure directory](infrastructure) contains [Terraform](https://www.terraform.io/) configuration files in order to deploy OpenEWS to AWS.

The infrastructure in this repository depends on some shared core infrastructure. This core infrastructure can be found in [The Somleng Project](https://github.com/somleng/somleng-project/tree/master/infrastructure) repository.

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
