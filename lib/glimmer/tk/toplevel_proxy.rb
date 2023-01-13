module Glimmer_Tk_ToplevelProxy_Override
  attr_accessor :modal, :centered
  alias_method :modal?, :modal
  alias_method :centered?, :centered

  def post_add_content
    if is_a?(Glimmer::Tk::ToplevelProxy) && modal?
      # TODO: what if x, y, width, height already set?
      center_within_root unless centered?
      root_parent_proxy.withdraw
      tk.grab_set
      on('WM_DELETE_WINDOW') do
        tk.grab_release
        root_parent_proxy.deiconify
        destroy
        true
      end
      on('destroy') do
        tk.grab_release
        root_parent_proxy.deiconify
        true
      end
    end

    if centered?
      center_within_screen
    end

    if is_a?(Glimmer::Tk::ToplevelProxy) && @tk.iconphoto.nil? && root_parent_proxy.iconphoto
      @tk.iconphoto = root_parent_proxy.iconphoto
    end

    super
  end

  def center_within_screen
    monitor_width, monitor_height = wm_maxsize
    update :idletasks
    current_width = width
    current_height = height

    if RbConfig::CONFIG['host_os'] == 'linux'
      begin
        # HDMI-A-0 connected primary 2560x1080+1024+100 (normal left inverted right x axis y axis) 798mm x 334mm
        sizes = `xrandr`
                  .split("\n")
                  .find { |line| line.include?(' connected primary ') }
                  &.match(/([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)/)
        raise "`xrandr` returned unexpected results. Try to run `xrandr`, verify it's output and possibly update this code." unless sizes

        self.x = (sizes[1].to_i - width) / 2 + sizes[3].to_i
        self.y = (sizes[2].to_i - height) / 2 + sizes[4].to_i

      rescue StandardError => e
        Glimmer::Config.logger.debug {"Unable to detect primary screen on Linux with xrandr"}
        Glimmer::Config.logger.debug {e.full_message}

        self.x = (winfo_screenwidth - width) / 2
        self.y = (winfo_screenheight - height) / 2
      end

    else
      self.x = (winfo_screenwidth - width) / 2
      self.y = (winfo_screenheight - height) / 2
    end

    self.width = width
    self.height = height
  end

  def center_within_root(margin: 0)
    self.x = root_parent_proxy.x + margin
    self.y = root_parent_proxy.y + margin
    self.width = root_parent_proxy.width - 2 * margin
    self.height = root_parent_proxy.height - 2 * margin
  end

  ::Glimmer::Tk::ToplevelProxy.prepend self
end
