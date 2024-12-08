import { doFetch } from "../common/fetch"
import { PaymentInfo } from "../common/types-class"
import { BACKEND_URL } from "../common/constants"
import { useCallback, useState, useEffect } from "react"

function CheckPayments() {

  const [ unpaid, setUnpaid ] = useState<string>()
  const fetchPaymentsDue = useCallback(() => {
    doFetch<PaymentInfo[]>(BACKEND_URL + '/payments')
    .then((json) => {
      for (let p of json) {
        console.log(p.status)
        if (p.status !== 'paid') {
          setUnpaid(p.status)
        }
      }
    })
  }, [])

  useEffect(() => {
    fetchPaymentsDue()
  }, [fetchPaymentsDue])

  if (typeof unpaid === 'undefined') {
    return (
      <span>&nbsp;</span>
    )
  } else {
    return (
      <span className='paymentAlert'>{unpaid}</span>
    )
  }

}

export default CheckPayments