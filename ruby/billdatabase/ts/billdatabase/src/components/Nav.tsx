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
  
  function endcrumb(linkname: string) : Crumb {
    return { link: undefined, description: linkname }
  }

  function breadcrumb() : Crumb[] {
    switch(page) {
      case NavType.Documents:
        return [HOME, endcrumb('Documents')]
      case NavType.NewDocument:
        return [HOME, DOCUMENTS, endcrumb('New Document')]
      case NavType.EditDocument:
        return [HOME, DOCUMENTS, endcrumb('Edit Document')]
      case NavType.Payments:
        return [HOME, DOCUMENTS, endcrumb('Payments')]
      case NavType.Senders:
        return [HOME, endcrumb('Senders')]
      case NavType.SenderContacts:
        return [HOME, endcrumb('Sender Contacts')]
      case NavType.NewSender:
        return [HOME, SENDERS, endcrumb('New Sender')]
      case NavType.EditSender:
        return [HOME, SENDERS, endcrumb('Edit Sender')]
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

/*
<div class='top_navigation'>
  <div class='link'>
    <% if page == 'documents' %>
    <a href="/main">Home</a> &gt; Documents
    <% elsif page == 'new document' %>
    <a href="/main">Home</a> &gt; <a href="/documents">Documents</a> &gt; New Document
    <% elsif page == 'edit document' %>
    <a href="/main">Home</a> &gt; <a href="/documents">Documents</a> &gt; Edit Document
    <% elsif page == 'payments' %>
    <a href="/main">Home</a> &gt; <a href="/documents">Documents</a> &gt; Payments
    <% elsif page == 'senders' %>
    <a href="/main">Home</a> &gt; Senders 
    <% elsif page == 'new sender' %>
    <a href="/main">Home</a> &gt; <a href="/senders">Senders</a> &gt; New Sender
    <% elsif page == 'edit sender' %>
    <a href="/main">Home</a> &gt; <a href="/senders">Senders</a> &gt; Edit Sender
    <% elsif page == 'sender contacts' %>
    <a href="/main">Home</a> &gt; <a href="/senders">Senders</a> &gt; Sender Contacts
    <% elsif page == 'document types' %>
    <a href="/main">Home</a> &gt; Document Types 
    <% elsif page == 'tag types' %>
    <a href="/main">Home</a> &gt; Tag Types 
    <% end %>
  </div>
</div> 
*/