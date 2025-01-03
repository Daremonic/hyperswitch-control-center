open NewPaymentsOverviewSectionTypes

let getStringFromVariant = value => {
  switch value {
  | Total_Smart_Retried_Amount => "total_smart_retried_amount_in_usd"
  | Total_Smart_Retried_Amount_Without_Smart_Retries => "total_smart_retried_amount_without_smart_retries_in_usd"
  | Total_Success_Rate => "total_success_rate"
  | Total_Success_Rate_Without_Smart_Retries => "total_success_rate_without_smart_retries"
  | Total_Payment_Processed_Amount => "total_payment_processed_amount_in_usd"
  | Total_Payment_Processed_Amount_Without_Smart_Retries => "total_payment_processed_amount_without_smart_retries_in_usd"
  | Total_Refund_Processed_Amount => "total_refund_processed_amount_in_usd"
  | Total_Dispute => "total_dispute"
  }
}

let defaultValue =
  {
    total_smart_retried_amount_in_usd: 0.0,
    total_smart_retried_amount_without_smart_retries_in_usd: 0.0,
    total_success_rate: 0.0,
    total_success_rate_without_smart_retries: 0.0,
    total_payment_processed_amount_in_usd: 0.0,
    total_payment_processed_count: 0,
    total_payment_processed_amount_without_smart_retries_in_usd: 0.0,
    total_payment_processed_count_without_smart_retries: 0,
    total_refund_processed_amount_in_usd: 0.0,
    total_dispute: 0,
  }
  ->Identity.genericTypeToJson
  ->LogicUtils.getDictFromJsonObject

let getPayload = (~entity, ~metrics, ~startTime, ~endTime) => {
  open NewAnalyticsTypes
  NewAnalyticsUtils.requestBody(
    ~startTime,
    ~endTime,
    ~delta=entity.requestBodyConfig.delta,
    ~metrics,
  )
}

let parseResponse = (response, key) => {
  open LogicUtils
  response
  ->getDictFromJsonObject
  ->getArrayFromDict(key, [])
  ->getValueFromArray(0, Dict.make()->JSON.Encode.object)
  ->getDictFromJsonObject
}

let setValue = (dict, ~data, ~ids: array<overviewColumns>) => {
  open LogicUtils

  ids->Array.forEach(id => {
    let key = id->getStringFromVariant
    let value = switch id {
    | Total_Smart_Retried_Amount
    | Total_Smart_Retried_Amount_Without_Smart_Retries
    | Total_Payment_Processed_Amount
    | Total_Payment_Processed_Amount_Without_Smart_Retries
    | Total_Refund_Processed_Amount =>
      data->NewAnalyticsUtils.getAmountValue(~id=id->getStringFromVariant)->JSON.Encode.float
    | _ =>
      data
      ->getFloat(id->getStringFromVariant, 0.0)
      ->JSON.Encode.float
    }

    dict->Dict.set(key, value)
  })
}

let getInfo = (~responseKey: overviewColumns) => {
  open NewAnalyticsTypes
  switch responseKey {
  | Total_Smart_Retried_Amount | Total_Smart_Retried_Amount_Without_Smart_Retries => {
      titleText: "Total Payment Savings",
      description: "Amount saved via payment retries",
      valueType: Amount,
    }
  | Total_Success_Rate | Total_Success_Rate_Without_Smart_Retries => {
      titleText: "Total Authorization Rate",
      description: "Overall successful payment intents divided by total payment intents excluding dropoffs",
      valueType: Rate,
    }
  | Total_Payment_Processed_Amount | Total_Payment_Processed_Amount_Without_Smart_Retries => {
      titleText: "Total Payments Processed",
      description: "The total amount of payments processed in the selected time range",
      valueType: Amount,
    }
  | Total_Refund_Processed_Amount => {
      titleText: "Total Refunds Processed",
      description: "The total amount of refund payments processed in the selected time range",
      valueType: Amount,
    }
  | Total_Dispute => {
      titleText: "All Disputes",
      description: "Total number of disputes irrespective of status in the selected time range",
      valueType: Volume,
    }
  }
}

let getValueFromObj = (data, index, responseKey) => {
  open LogicUtils
  data
  ->getArrayFromJson([])
  ->getValueFromArray(index, Dict.make()->JSON.Encode.object)
  ->getDictFromJsonObject
  ->getFloat(responseKey, 0.0)
}

let getKeyForModule = (field, ~metricType) => {
  open NewAnalyticsTypes
  switch (field, metricType) {
  | (Total_Smart_Retried_Amount, Smart_Retry) => Total_Smart_Retried_Amount
  | (Total_Payment_Processed_Amount, Smart_Retry) => Total_Payment_Processed_Amount
  | (Total_Success_Rate, Smart_Retry) => Total_Success_Rate
  | (Total_Smart_Retried_Amount, Default) => Total_Smart_Retried_Amount_Without_Smart_Retries
  | (Total_Success_Rate, Default) => Total_Success_Rate_Without_Smart_Retries
  | (Total_Payment_Processed_Amount, Default) =>
    Total_Payment_Processed_Amount_Without_Smart_Retries
  | (Total_Refund_Processed_Amount, _) => Total_Refund_Processed_Amount
  | (Total_Dispute, _) | _ => Total_Dispute
  }
}
