
interface EditFieldProps {
  /** field name to match your document field in the callback */
  fieldName: string,
  initialValue?: string,
  mandatory?: boolean,
  fieldType: "text" | "date" | "textarea",
  /** function to be called (and passed { yourFieldName: 'the value' }) each time field changes */
  changeCallback: (newvalue : Object) => void,
}


function EditField (props: EditFieldProps) {  
  
  const doCallbackWithField = (field: string, val : string) => {
    const fieldObj : any = {}
    fieldObj[field] = val
    // console.log('firing callback: ')
    // console.log(fieldObj)
    props.changeCallback(fieldObj)
  }
  // console.log("PROPS.FIELDTYPE = '" + props.fieldType + "'")
  const isMandatory = !(props.mandatory === undefined || props.mandatory === false)
  const classNameStr = isMandatory ? 'sender_field mandatory' : 'sender_field'
  
  if (props.fieldType === "date") {
    // don't think placeholders work for input type date :-)
    return(
      <input type="date"
      className={classNameStr} 
      defaultValue={props.initialValue !== undefined ? props.initialValue : ''}
      onChange={(e) => doCallbackWithField(props.fieldName, e.target.value)}
      name={props.fieldName} />
    )

  } else if (props.fieldType === "textarea") {
    return (
      <textarea 
      placeholder={isMandatory ? 'Mandatory field' : ''}
      className={classNameStr} 
      onChange={(e) => doCallbackWithField(props.fieldName, e.target.value)}
      name={props.fieldName} rows={5} >
        {props.initialValue !== undefined ? props.initialValue : ''}
      </textarea>
    )
  }
  return (
    <input 
    className={classNameStr} 
    placeholder={isMandatory ? 'Mandatory field' : ''}
    defaultValue={props.initialValue !== undefined ? props.initialValue : ''}
    onChange={(e) => doCallbackWithField(props.fieldName, e.target.value)}
    name={props.fieldName} />

  ) 
  
}

export default EditField