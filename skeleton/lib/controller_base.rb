require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
require 'pathname'
class ControllerBase
  attr_reader :req, :res, :params
  # Setup the controller
  def initialize(req, res)
    @res = res
    @req = req
  end

  # Helper method to alias @already_built_response
  def already_built_response?
      @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Already rendered" if already_built_response?
    res['Content-Type'] = 'text/html'
    res.status = 302
    res.location = url
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Already rendered" if already_built_response?
    res['Content-Type'] = content_type
    res.write(content)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    
    # 1 - path = set up your path
    # 1a look up ActiveSupport#underscore
    # 1b think of following path views/#{controller_name}/template_name.html.erb
    # 2 - file = File.read(path)
    # 3 - create your ERB template with ERB.new(file)
    pn = Pathname(__FILE__).dirname.parent.to_s
    path = pn + ActiveSupport::Inflector.underscore("/Views::#{self.class.name}") + "/#{template_name}.html.erb"
    file = File.read(path)
    result = ERB.new(file).result(binding)
    render_content(result, 'text/html')
  end

  # method exposing a `Session` object
  def session
    JSON.parse(req.cookies)
    # req.env["rack.request.cookie_string"]
    #JSON.parse(req.)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

