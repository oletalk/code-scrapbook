import { NavType } from "../common/types-class"
import Nav from '../components/Nav'
import { Link } from "react-router-dom"
import { doFetch } from "../common/fetch"
import { PaymentInfo } from "../common/types-class"
import { BACKEND_URL } from "../common/constants"
import { useCallback, useState, useEffect } from "react"

function ViewPayments() {

  const [ payments, setPayments ] = useState<PaymentInfo[]>()

  const fetchPaymentsDue = useCallback(() => {
    doFetch<PaymentInfo[]>(BACKEND_URL + '/payments')
    .then((json) => {
      setPayments(json)
    })
  }, [])

  useEffect(() => {
    fetchPaymentsDue()
  }, [fetchPaymentsDue])

  const hdr = <div>
      <Nav page={NavType.Payments} />
    <h2>Due Payments</h2>
    </div>

  if (typeof payments === 'undefined' || payments.length === 0) {
    return (
      <div>
        {hdr}
        <div>no payments due recently</div>
      </div>
      
    )
  } else {
    return (
      <div>
        {hdr}
        <table className="paymentInfo">
          <tr><th>Due Date</th><th>Paid Date</th><th>Sender</th><th>Summary</th></tr>
        {payments.map(p => (
          <tr className={'payment-' + p.status}>
            <td>{p.due_date}</td><td>{p.paid_date}</td>
            <td>{p.name}</td>
            <td><Link to={'/document/' + p.document_id}>{p.summary}</Link></td>
          </tr>
        ))}
        </table>
      </div>
    )
  }

}

export default ViewPayments