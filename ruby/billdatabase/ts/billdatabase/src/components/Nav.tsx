import { Link } from 'react-router-dom';
import { NavType } from '../common/types-class'
interface NavProps {
  page: NavType
}
interface Crumb {
  link: string | undefined,
  description: string
}
function MainNav (props: NavProps) {

  const page = props.page
  const HOME: Crumb = { link: '/main', description: 'Home' }
  const DOCUMENTS: Crumb = { link: '/documents', description: 'Documents' }
  const SENDERS: Crumb = { link: '/senders', description: 'Senders' }
  
  function docPathTo(endcrumbname: string) : Crumb[] {
    return [HOME, DOCUMENTS, endcrumb(endcrumbname)]
  }
  function senderPathTo(endcrumbname: string) : Crumb[] {
    return [HOME, SENDERS, endcrumb(endcrumbname)]
  }

  function endcrumb(linkname: string) : Crumb {
    return { link: undefined, description: linkname }
  }

  function breadcrumb() : Crumb[] {
    switch(page) {
      case NavType.Documents:
        return [HOME, endcrumb('Documents')]
      case NavType.NewDocument:
        return docPathTo('New Document')
      case NavType.EditDocument:
        return docPathTo('Edit Document')
      case NavType.Payments:
        return docPathTo('Payments')
      case NavType.Senders:
        return [HOME, endcrumb('Senders')]
      case NavType.SenderContacts:
        return [HOME, endcrumb('Sender Contacts')]
      case NavType.NewSender:
        return senderPathTo('New Sender')
      case NavType.EditSender:
        return senderPathTo('Edit Sender')
      case NavType.DocumentTypes:
        return [HOME, endcrumb('Document Types')]
      case NavType.TagTypes:
        return [HOME, endcrumb('Tag Types')]
            default:
        return [HOME]
    }
  }
  return (
    <div className='top_navigation'>
    <div className='link'>
    </div>
    {breadcrumb().map(crumb =>
     crumb.link !== undefined ?
      <span><Link to={crumb.link}>{crumb.description}</Link> &gt; </span>
      : <span>{crumb.description}</span>
  )}
  
  </div> 
  )
}

/*           <li><Link to="/senders">Senders</Link></li> */

export default MainNav;