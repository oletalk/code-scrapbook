
interface EditFieldProps {
  fieldName: string,
  fieldType: "text" | "date" | "textarea",
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
  if (props.fieldType === "date") {
    return(
      <input type="date"
      className='sender_field' 
      onChange={(e) => doCallbackWithField(props.fieldName, e.target.value)}
      name={props.fieldName} />
    )

  } else if (props.fieldType === "textarea") {
    return (
      <textarea 
      className='sender_field' 
      onChange={(e) => doCallbackWithField(props.fieldName, e.target.value)}
      name={props.fieldName} rows={5} />
    )
  }
  return (
    <input 
    className='sender_field' 
    onChange={(e) => doCallbackWithField(props.fieldName, e.target.value)}
    name={props.fieldName} />

  ) 
  
}

export default EditField