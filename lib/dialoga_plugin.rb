class DialogaPlugin < Noosfero::Plugin

  def self.plugin_name
    _('Dialoga custom plugin')
  end

  def self.plugin_description
    _("Provide a plugin to dialoga environment.")
  end

  def self.api_mount_points
    [DialogaPlugin::API ]
  end

end
