class App.TicketPriority extends App.Model
  @configure 'TicketPriority', 'name', 'note', 'active'
  @extend Spine.Model.Ajax
  @url: '/ticket_priorities'