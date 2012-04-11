class App.Organization extends App.Model
  @configure 'Organization', 'name', 'shared', 'note', 'active'
  @extend Spine.Model.Ajax
  @configure_attributes = [
    { name: 'name',       display: 'Name', tag: 'input', type: 'text', limit: 100, 'null': false, 'class': 'xlarge' },
    { name: 'note',       display: 'Note', note: 'Notes are visible to agents only, never to customers.', tag: 'textarea', limit: 250, 'null': true, 'class': 'xlarge' },
    { name: 'shared',     display: 'Shared organiztion', note: 'Customers in the organiztion can view each other items.', tag: 'boolean', type: 'boolean', 'default': true, 'null': false, 'class': 'xlarge' },
    { name: 'updated_at', display: 'Updated', type: 'time', readonly: 1 },
    { name: 'active',     display: 'Active', tag: 'boolean', type: 'boolean', 'default': true, 'null': false, 'class': 'xlarge' },
  ]
  @configure_overview = [
    'name', 'shared',
  ]