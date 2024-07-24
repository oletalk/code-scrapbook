import { NavType } from "../common/types-class"
import Nav from "../components/Nav"

function CreateDocument () {

  return (
    <div>
      <Nav page={NavType.NewDocument} />
      <div> add new document </div>
    </div>
  )
}

export default CreateDocument