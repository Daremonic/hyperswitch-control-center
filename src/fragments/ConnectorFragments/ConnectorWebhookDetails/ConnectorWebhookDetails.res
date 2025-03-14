@react.component
let make = (
  ~showVertically=true,
  ~labelTextStyleClass="",
  ~labelClass="font-semibold ",
  ~isInEditState,
  ~connectorInfo: ConnectorTypes.connectorPayload,
) => {

  open LogicUtils
  open ConnectorHelperV2
  let connector = UrlUtils.useGetFilterDictFromUrl("")->getString("name", "")
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let connectorTypeFromName = connector->ConnectorUtils.getConnectorNameTypeFromString

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])

  let connectorWebHookDetails = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = Window.getConnectorConfig(connector)

        dict->getDictFromJsonObject->getDictfromDict("connector_webhook_details")
      } else {
        Dict.make()
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR WEBHOOK CONFIG", e)
        Dict.make()
      }
    }
  }, [selectedConnector])

  let checkIfRequired = (connector, field) => {
    ConnectorUtils.getWebHookRequiredFields(connector, field)
  }

  let webHookDetails = connectorInfo.connector_webhook_details->getDictFromJsonObject
  let keys = connectorWebHookDetails->Dict.keysToArray
  <>
    {keys
    ->Array.mapWithIndex((field, index) => {
      let label = connectorWebHookDetails->getString(field, "")
      let value = webHookDetails->getString(field, "")

      <RenderIf key={index->Int.toString} condition={label->String.length > 0}>
        <div>
          {if isInEditState {
            <>
              <FormRenderer.FieldRenderer
                labelClass
                field={FormRenderer.makeFieldInfo(
                  ~label,
                  ~name={`connector_webhook_details.${field}`},
                  ~placeholder={label},
                  ~customInput=InputFields.textInput(~customStyle="rounded-xl "),
                  ~isRequired=checkIfRequired(connectorTypeFromName, field),
                )}
                labelTextStyleClass
              />
              <ConnectorAuthKeysHelper.ErrorValidation
                fieldName={`connector_webhook_details.${field}`}
                validate={ConnectorUtils.validate(
                  ~selectedConnector,
                  ~dict=connectorWebHookDetails,
                  ~fieldName={`connector_webhook_details.${field}`},
                  ~isLiveMode={featureFlagDetails.isLiveMode},
                )}
              />
            </>
          } else {
            <RenderIf condition={value->String.length > 0}>
              <InfoField label str={value} />
            </RenderIf>
          }}
        </div>
      </RenderIf>
    })
    ->React.array}
  </>
}
