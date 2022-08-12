
## Features

- Discover drones flying nearby in real-time
- Examine detailed information broadcasted by drones via Bluetooth 4, Bluetooth 5, Wi-Fi Beacon, and Wi-Fi NAN
- Browse a detailed map with your location and all nearby aircraft
- Check available data about drones, including real-time height, direction, pilot identification, pilot position, operation description, and location history
- Various flying zones marked and highlighted on the map
- Easy export of collected data
- Continuously updated to reflect the latest EU & US regulations

## Regulatory compliance

The application is compliant with latest regulation on drone industry.
Current leaders in developing drone legislation and regulations are the USA and the EU. In both political entities, there are already approved regulations that administer the operations of Unmanned Autonomous Vehicle (UAV). In the EU, European Commission has adopted a Commission Delegated Regulation 2019/945 of 12 March 2019 on unmanned aircraft systems and on third-country operators of unmanned aircraft systems and Commission Implementing Regulation 2019/947 of 24 May 2019 on the rules and procedures for the operation of unmanned aircraft. In the USA, the Federal Aviation Admin- istration (FAA), which is an agency within the Department of Transportation, published a Federal Aviation Regulation, Rule 89. Regulations provide a general framework for the operation of UAV without specifying technical details. 

The article 6 of regulation 2019/945 states that: ”Each Unmanned Aircraft (UA) intended to be operated in the ”specific” category and at a height below 120 meters shall be equipped with a Remote ID system”.

### United States

The [ASTM F3411](https://www.astm.org/Standards/F3411.htm) Specification for Remote ID and Tracking has been defined to specify how Unmanned Aircraft (UA) or Unmanned Aircraft Systems (UAS) can publish their ID, location, altitude etc., either via direct broadcast (Bluetooth or Wi-Fi), or via an internet connection to a Remote ID server.

Version 1.1 (F3411-22a) of the specification is available: https://www.astm.org/f3411-22a.html

The updated version F3411-22a contains smaller changes/additions to make the message content etc. better suited to meet the [rule](https://www.regulations.gov/document/FAA-2019-1100-53264) defined by the [FAA](https://www.faa.gov/uas/getting_started/remote_id/) (Federal Aviation Administration) for [UAS flights](https://www.faa.gov/uas/commercial_operators/operations_over_people/) in the United States.

Together, the three documents ([F3411](https://www.astm.org/f3411-22a.html), [F3586](https://www.astm.org/f3586-22.html) and the [NoA](https://www.federalregister.gov/documents/2022/08/11/2022-16997/accepted-means-of-compliance-remote-identification-of-unmanned-aircraft)) allows manufacturers of UAS and remote ID broadcast modules/Add-ons to implement remote ID support and create the necessary Declaration of Compliance (DoC) document, which must be submitted to the FAA for approval.

Operators of UAS have thirty months since January 2021 to comply with the regulation, and manufacturers have 18 months after the pub- lication date to comply.

### European Union

To meet the European Commission Delegated Regulation [2019/945](https://eur-lex.europa.eu/eli/reg_del/2019/945/2020-08-09) and the Commission Implementing Regulation [2019/947](https://eur-lex.europa.eu/eli/reg_impl/2019/947/2021-08-05), ASD-STAN has developed the prEN 4709-002 Direct Remote Identification specification.
It specifies broadcast methods for Remote ID (Bluetooth and Wi-Fi) that are compliant with the ASTM F3411 v1.1 specification.

The final version of the standard has been published [here](http://asd-stan.org/downloads/asd-stan-pren-4709-002-p1/).
See also the summary [whitepaper](https://asd-stan.org/wp-content/uploads/ASD-STAN_DRI_Introduction_to_the_European_digital_RID_UAS_Standard.pdf) and the recording of this [webinar](https://www.cencenelec.eu/news-and-events/events/2021-02-09-european-workshop-on-uas-direct-remote-identification/).

The most recent information that we were able to find says that UAS that would otherwise be in the ”specific” category are allowed to be used in the ”open” category for a transitional period ending on 1 January 2023.

## Supported smartphones

- the ability of a phone to receive Bluetooth 5 Extended Advertisements must be proven experimentally. A list of smartphones that have been tested for receiving Remote ID signals is available [here](https://github.com/opendroneid/receiver-android/blob/master/supported-smartphones.md).

