require "weaver/version"

require 'fileutils'
require 'sinatra'

module Weaver

	class Elements

		def initialize(anchors)
			@inner_content = []
			@anchors = anchors
		end

		def method_missing(name, *args, &block)
			tag = "<#{name} />"

			if args[0].is_a? String
				inner = args.shift
			end
			if block
				elem = Elements.new(@anchors)
				elem.instance_eval(&block)
				inner = elem.generate
			end

			if !inner
				tag = "<#{name} />"
			elsif args.length == 0
				tag = "<#{name}>#{inner}</#{name}>"
			elsif args.length == 1 and args[0].is_a? Hash
				options = args[0]
				opts = options.map { |key,value| "#{key}=\"#{value}\"" }.join " "
				tag = "<#{name} #{opts}>#{inner}</#{name}>"
			end

			@inner_content << tag
			tag
		end

		def icon(type)
			iconname = type.to_s.gsub(/_/, "-")
			i class: "fa fa-#{iconname}" do
			end
		end

        def ibox(&block)
        	panel = Panel.new(@anchors)
        	panel.instance_eval(&block)
        	@inner_content << panel.generate
        end

        def panel(title, &block)
        	div class: "panel panel-default" do
        		div class: "panel-heading" do
	    				h5 title
	    			end 
        		div class: "panel-body", &block
        	end
        end

		def breadcrumb(patharray)
			ol class: "breadcrumb" do
				patharray.each do |path|
					li path
				end
			end
		end

		def p(*args, &block)
			method_missing(:p, *args, &block)
		end

		def text(theText)
			@inner_content << theText
		end

		def link(url, title=nil)
			if !title
				title = url
			end

			a href: url, target: "_blank" do
				span do
					text title
					text " "
					icon :external_link
				end
			end
		end

		def accordion(&block)
			acc = Accordion.new(@anchors)
			acc.instance_eval(&block)

			@inner_content << acc.generate
		end

		def widget(options={}, &block)
			#gray-bg
			#white-bg
			#navy-bg
			#blue-bg
			#lazur-bg
			#yellow-bg
			#red-bg
			#black-bg

			color = "#{options[:color]}-bg" || "navy-bg"

			div :class => "widget style1 #{color}", &block
		end

		def jumbotron(&block)
			div :class => "jumbotron", &block
		end

		def _button(options={})

			anIcon = options[:icon]
			title = options[:title]

			if title.is_a? Hash
				options.merge! title
				title = anIcon
				anIcon = nil

			end

			style = options[:style] || :primary
			size = "btn-#{options[:size]}" if options[:size]
			block = "btn-block" if options[:block]
			outline = "btn-outline" if options[:outline]
			dim = "dim" if options[:threedee]
			dim = "dim btn-large-dim" if options[:bigthreedee]
			dim = "btn-rounded" if options[:rounded]
			dim = "btn-circle" if options[:circle]

			buttonOptions = {
				:type => "button",
				:class => "btn btn-#{style} #{size} #{block} #{outline} #{dim}"
			}

			type = :button

			buttonOptions[:"data-toggle"] = "button" if options[:toggle]
			type = :a if options[:toggle]


			method_missing type, buttonOptions do
				if title.is_a? Symbol
					icon title
				else
					icon anIcon if anIcon
					text " " if anIcon
					text title
				end
			end
		end

		def button(anIcon, title, options={})
			options[:icon] = anIcon
			options[:title] = title
			_button(options)
		end

		def block_button(anIcon, title, options={})
			options[:block] = true
			options[:icon] = anIcon
			options[:title] = title
			_button(options)
		end

		def outline_button(anIcon, title, options={})
			options[:outline] = true
			options[:icon] = anIcon
			options[:title] = title
			_button(options)
		end

		def big_button(anIcon, title, options={})
			options[:size] = :lg
			options[:icon] = anIcon
			options[:title] = title
			_button(options)
		end

		def small_button(anIcon, title, options={})
			options[:size] = :sm
			options[:icon] = anIcon
			options[:title] = title
			_button(options)
		end

		def tiny_button(anIcon, title, options={})
			options[:size] = :xs
			options[:icon] = anIcon
			options[:title] = title
			_button(options)
		end

		def embossed_button(anIcon, title, options={})
			options[:threedee] = true
			options[:icon] = anIcon
			options[:title] = title
			_button(options)
		end

		def big_embossed_button(anIcon, title, options={})
			options[:bigthreedee] = true
			options[:icon] = anIcon
			options[:title] = title
			_button(options)
		end

		def rounded_button(anIcon, title, options={})
			options[:rounded] = true
			options[:icon] = anIcon
			options[:title] = title
			_button(options)
		end

		def circle_button(anIcon, title, options={})
			options[:circle] = true
			options[:icon] = anIcon
			options[:title] = title
			_button(options)
		end

		def table_from_hashes(hashes)

			keys = {}
			hashes.each do |hash|
				hash.each do |key,value|
					keys[key] = ""
				end
			end

			table class: "table" do

				thead do
					keys.each do |key, _| 
						th key.to_s
					end
				end

				hashes.each do |hash|

					tr do
						keys.each do |key, _|
							td hash[key] || "&nbsp;"
						end
					end
				end

			end
		end

		def generate
			@inner_content.join
		end
	end

	class Panel < Elements
		def initialize(anchors)
			super(anchors)
			@title = nil
			@footer = nil
			@type = :ibox
			@tabs = nil
			@body = true
			@extra = nil
			@min_height = nil
		end

		def generate
			inner = super

        	types =
        	{
        		:ibox  => 	{ outer: "ibox float-e-margins",header: "ibox-title",    body: "ibox-content" , footer: "ibox-footer"},
        		:panel => 	{ outer: "panel panel-default", header: "panel-heading", body: "panel-body"   , footer: "panel-footer"},
        		:primary => { outer: "panel panel-primary", header: "panel-heading", body: "panel-body"   , footer: "panel-footer"},
        		:success => { outer: "panel panel-success", header: "panel-heading", body: "panel-body"   , footer: "panel-footer"},
        		:info => 	{ outer: "panel panel-info",  	header: "panel-heading", body: "panel-body"   , footer: "panel-footer"},
        		:warning => { outer: "panel panel-warning", header: "panel-heading", body: "panel-body"   , footer: "panel-footer"},
        		:danger => 	{ outer: "panel panel-danger",  header: "panel-heading", body: "panel-body"   , footer: "panel-footer"},
        		:blank => 	{ outer: "panel blank-panel",   header: "panel-heading", body: "panel-body"   , footer: "panel-footer"}
        	}

        	title = @title
        	footer = @footer
        	tabs = @tabs
        	hasBody = @body
        	extra = @extra
        	classNames = types[@type]
			min_height = @min_height

        	elem = Elements.new(@anchors)

        	elem.instance_eval do
				div class: classNames[:outer] do
					if title or tabs
						div class: classNames[:header] do
							text title if title
							text tabs.generate_tabs if tabs
						end
					end
					if hasBody
						div class: classNames[:body], style: "min-height: #{min_height}px" do 
							text inner
							text tabs.generate_body if tabs
						end
					end
					if extra
						text extra
					end
					if footer
						div class: classNames[:footer] do 
							text footer
						end
					end
				end
        	end

        	elem.generate
		end

		def min_height(val)
			@min_height = val
		end

		def type(aType)
			@type = aType
		end

		def body(hasBody)
			@body = hasBody
		end

		def title(title=nil, &block)
			@title = title
			if block
				elem = Elements.new(@anchors)
				elem.instance_eval(&block)
				@title = elem.generate
			end
		end

		def extra(&block)
			if block
				elem = Elements.new(@anchors)
				elem.instance_eval(&block)
				@extra = elem.generate
			end
		end

		def footer(footer=nil, &block)
			@footer = footer
			if block
				elem = Elements.new(@anchors)
				elem.instance_eval(&block)
				@footer = elem.generate
			end
		end

		def tabs(&block)
			tabs = Tabs.new(@anchors)
			tabs.instance_eval(&block)

			@tabs = tabs
		end
	end

	class Accordion
		def initialize(anchors)
			@anchors = anchors
			@tabs = {}
			@paneltype = :panel
			@is_collapsed = false

			if !@anchors["accordia"]
				@anchors["accordia"] = []
			end

			accArray = @anchors["accordia"]

			@accordion_name = "accordion#{accArray.length}"
			accArray << @accordion_name
		end

		def collapsed(isCollapsed)
			@is_collapsed = isCollapsed
		end

		def type(type)
			@paneltype = type
		end

		def tab(title, &block)
			
			if !@anchors["tabs"]
				@anchors["tabs"] = []
			end

			tabArray = @anchors["tabs"]

			elem = Elements.new(@anchors)
			elem.instance_eval(&block)

			tabname = "tab#{tabArray.length}"
			tabArray << tabname

			@tabs[tabname] = 
			{
				title: title,
				elem: elem
			}

		end

		def generate
			tabbar = Elements.new(@anchors)

			tabs = @tabs
			paneltype = @paneltype
			accordion_name = @accordion_name
			is_collapsed = @is_collapsed

			tabbar.instance_eval do

				div :class => "panel-group", id: accordion_name do

					cls = "panel-collapse collapse in"
					cls = "panel-collapse collapse" if is_collapsed
					tabs.each do |anchor, value|

						ibox do
							type paneltype
							body false
							title do
								div :class => "panel-title" do
									a :"data-toggle" => "collapse", :"data-parent" => "##{accordion_name}", href: "##{anchor}" do
										if value[:title].is_a? Symbol
											icon value[:title]
										else
											text value[:title]
										end
									end
								end
							end

							extra do 
								div id: anchor, :class => cls do
									div :class => "panel-body" do
										text value[:elem].generate
									end
								end
							end
						end

						cls = "panel-collapse collapse"
					end

				end

			end

			tabbar.generate
		end

	end

	class Tabs
		def initialize(anchors)
			@anchors = anchors
			@tabs = {}
		end

		def tab(title, &block)
			
			if !@anchors["tabs"]
				@anchors["tabs"] = []
			end

			tabArray = @anchors["tabs"]

			elem = Elements.new(@anchors)
			elem.instance_eval(&block)

			tabname = "tab#{tabArray.length}"
			tabArray << tabname

			@tabs[tabname] = 
			{
				title: title,
				elem: elem
			}

		end

		def generate_body
			tabbar = Elements.new(@anchors)
			tabs = @tabs

			tabbar.instance_eval do

				div :class => "tab-content" do

					cls = "tab-pane active"
					tabs.each do |anchor, value|
						div id: "#{anchor}", :class => cls do
							text value[:elem].generate
						end
						cls = "tab-pane"
					end
				end
			end

			tabbar.generate
		end

		def generate_tabs

			tabbar = Elements.new(@anchors)
			tabs = @tabs

			tabbar.instance_eval do

				div :class => "panel-options" do

					ul :class => "nav nav-tabs" do
						cls = "active"
						tabs.each do |anchor, value|
							li :class => cls do
								a :"data-toggle" => "tab", href: "##{anchor}" do
									if value[:title].is_a? Symbol
										icon value[:title]
									else
										text value[:title]
									end
								end
							end

							cls = ""
						end
					end
				end
			end

			tabbar.generate
		end
	end

	class Page

		def initialize(title)
			@title = title
			@content = ""
			@body_class = nil
			@anchors = {}
		end

		def generate(back_folders, options={})

			mod = "../" * back_folders

			style = <<-ENDSTYLE
	<link href="#{mod}css/style.css" rel="stylesheet">
			ENDSTYLE

			if options[:style] == :empty
				style = ""
			end

			body_tag = "<body>"

			body_tag = "<body class='#{@body_class}'>" if @body_class

			loading_bar = ""
			loading_bar = '<script src="js/plugins/pace/pace.min.js"></script>' if @loading_bar_visible

			<<-SKELETON
<!DOCTYPE html>
<html>
<!-- Generated using weaver: https://github.com/davidsiaw/weaver -->
<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>#{@title}</title>

    <link href="#{mod}css/bootstrap.min.css" rel="stylesheet">
    <link href="#{mod}font-awesome/css/font-awesome.css" rel="stylesheet">
    <link href="#{mod}css/plugins/iCheck/custom.css" rel="stylesheet">
    #{style}
    <link href="#{mod}css/animate.css" rel="stylesheet">
    
</head>

#{body_tag}

#{@content}

    <!-- Mainly scripts -->
    <script src="#{mod}js/jquery-2.1.1.js"></script>
    <script src="#{mod}js/jquery-ui-1.10.4.min.js"></script>
    <script src="#{mod}js/bootstrap.min.js"></script>
    <script src="#{mod}js/plugins/metisMenu/jquery.metisMenu.js"></script>
    <script src="#{mod}js/plugins/slimscroll/jquery.slimscroll.min.js"></script>

    <!-- Custom and plugin javascript -->
    <script src="#{mod}js/inspinia.js"></script>
    #{loading_bar}
    

</body>

</html>

			SKELETON
		end
	end

	class Row
		attr_accessor :extra_classes

		def initialize(anchors, options)
			@columns = []
			@free = 12
			@extra_classes = options[:class] || ""
			@anchors = anchors
		end

		def twothirds(&block)
			opts =
			{
				xs: 12,
				sm: 12,
				md: 8,
				lg: 8
			}
			col(4, opts, &block)
		end

		def half(&block)
			opts =
			{
				xs: 12,
				sm: 12,
				md: 12,
				lg: 6
			}
			col(4, opts, &block)
		end

		def third(&block)
			opts =
			{
				xs: 12,
				sm: 12,
				md: 4,
				lg: 4
			}
			col(4, opts, &block)
		end

		def quarter(&block)
			opts =
			{
				xs: 12,
				sm: 12,
				md: 6,
				lg: 3
			}
			col(3, opts, &block)
		end


		def col(occupies, options={}, &block)
			raise "Not enough columns!" if @free < occupies
			elem = Elements.new(@anchors)
			elem.instance_eval(&block)

			@columns << { occupy: occupies, elem: elem, options: options }
			@free -= occupies 
		end

		def generate
			@columns.map { |col|

				xs = col[:options][:xs] || col[:occupy]
				sm = col[:options][:sm] || col[:occupy]
				md = col[:options][:md] || col[:occupy]
				lg = col[:options][:lg] || col[:occupy]

				<<-ENDCOLUMN
		<div class="col-xs-#{xs} col-sm-#{sm} col-md-#{md} col-lg-#{lg}">
			#{col[:elem].generate}
		</div>
				ENDCOLUMN
			}.join
		end
	end

	class Menu
		attr_accessor :items
		def initialize()
			@items = []
		end

		def nav(name, icon=:question, url=nil, &block)
			if url 
				@items << { name: name, link: url, icon: icon }
			end
			if block
				menu = Menu.new
				menu.instance_eval(&block)
				@items << { name: name, menu: menu, icon: icon }
			end
		end
	end

	class NavPage < Page
		def initialize(title)
			super
			@menu = Menu.new
		end

		def menu(&block)
			@menu.instance_eval(&block)
		end

	end


	class SideNavPage < NavPage
		def initialize(title)
			@rows = []
			super
		end

		def header(&block)
			row(class: "wrapper border-bottom white-bg page-heading", &block)
		end

		def row(options={}, &block)
			r = Row.new(@anchors, options)
			r.instance_eval(&block)
			@rows << r
		end

		def generate(level)
			rows = @rows.map { |row|
				<<-ENDROW
	<div class="row #{row.extra_classes}">
#{row.generate}
	</div>
				ENDROW
			}.join

			menu = @menu


			navigation = Elements.new(@anchors)
			navigation.instance_eval do

				menu.items.each do |item|
					li do
						if item.has_key? :menu


							a href:"#" do
								icon item[:icon]
								span :class => "nav-label" do
									text item[:name]
								end
								span :class => "fa arrow" do
									text ""
								end
							end

            				ul :class => "nav nav-second-level" do
            					item[:menu].items.each do |inneritem|
            						li do
            							if inneritem.has_key?(:menu)
            								raise "Second level menu not supported"
            							else
                							a href:inneritem[:link] do
                								text inneritem[:name]
                							end
            							end
            						end
            					end
                    		end
						elsif
							a href: "#" do
								span :class => "nav-label" do
									text item[:name]
								end
							end
						end
					end
				end

			end

			@loading_bar_visible = true
			@content =
			<<-ENDBODY
	<div id="wrapper">

		<nav class="navbar-default navbar-static-side" role="navigation">
			<div class="sidebar-collapse">
				<ul class="nav" id="side-menu">

	                <li>
	                    <a href="#"><i class="fa fa-home"></i> <span class="nav-label">X</span> <span class="label label-primary pull-right"></span></a>
	                </li>

		            #{navigation.generate}
				</ul>
			</div>
		</nav>
		<div id="page-wrapper" class="gray-bg">
			<div class="row border-bottom">
		        <nav class="navbar navbar-static-top  " role="navigation" style="margin-bottom: 0">
					<div class="navbar-header">
					    <a class="navbar-minimalize minimalize-styl-2 btn btn-primary " href="#"><i class="fa fa-bars"></i> </a>
					</div>
		            <ul class="nav navbar-top-links navbar-right">
		                <!-- NAV RIGHT -->
		            </ul>
		        </nav>
	        </div>
#{rows}
		</div>
	</div>
			ENDBODY

			super
		end
	end

	class TopNavPage < NavPage
		def initialize(title)
			@rows = []
			super
		end

		def nav(&block)
		end

		def header(&block)
			row(class: "wrapper border-bottom white-bg page-heading", &block)
		end

		def row(options={}, &block)
			r = Row.new(@anchors, options)
			r.instance_eval(&block)
			@rows << r
		end

		def generate(level)
			rows = @rows.map { |row|
				<<-ENDROW
	<div class="row #{row.extra_classes}">
#{row.generate}
	</div>
				ENDROW
			}.join

			@body_class = "top-navigation"
			@loading_bar_visible = true

			menu = @menu

			navigation = Elements.new(@anchors)
			navigation.instance_eval do

				menu.items.each do |item|
					li do
						if item.has_key? :menu

                    		li :class => "dropdown" do
                    			a :"aria-expanded" => "false", 
                    				role: "button", 
                    				href: "#", 
                    				:class => "dropdown-toggle", 
                    				:"data-toggle" => "dropdown" do

									icon item[:icon]
                    				text item[:name]
                    				span :class => "caret" do
                    					text ""
                    				end

                    			end
                				ul role: "menu", :class => "dropdown-menu" do
                					item[:menu].items.each do |inneritem|
                						li do
                							if inneritem.has_key?(:menu)
                								raise "Second level menu not supported"
                							else
	                							a href:inneritem[:link] do
	                								text inneritem[:name]
	                							end
                							end
                						end
                					end
                				end
                    		end
						elsif
							a href: "#" do
								span :class => "nav-label" do
									icon item[:icon]
									text item[:name]
								end
							end
						end
					end
				end

			end

			@content =
			<<-ENDBODY
	<div id="wrapper">

        <div id="page-wrapper" class="gray-bg">
	        <div class="row border-bottom white-bg">

				<nav class="navbar navbar-static-top" role="navigation">
				    <div class="navbar-header">
		                <button aria-controls="navbar" aria-expanded="false" data-target="#navbar" data-toggle="collapse" class="navbar-toggle collapsed" type="button">
		                    <i class="fa fa-reorder"></i>
		                </button>
						<a href="#" class="navbar-brand">X</a>
		            </div>
		            <div class="navbar-collapse collapse" id="navbar">
		                <ul class="nav navbar-nav">
#{navigation.generate}
		                </ul>
		                <ul class="nav navbar-top-links navbar-right">
		                	<!-- NAV RIGHT -->
		                </ul>
		            </div>



				</nav>
			</div>


	        <div class="wrapper-content">
	            <div class="container">
#{rows}
	            </div>
			</div>
		</div>
	</div>
			ENDBODY

			super
		end
	end


	class CenterPage < Page
		def initialize(title, element)
			@element = element
			super(title)
		end

		def generate(level)
			@body_class = "gray-bg"
			@content = <<-CONTENT
	<div class="middle-box text-center animated fadeInDown">
		<div>
			#{@element.generate}
		</div>
	</div>
			CONTENT
			super
		end
	end

	class Weave
		attr_accessor :pages
		def initialize(file)
			@pages = {}
			@file = file
			instance_eval(File.read(file), file)
		end

		def center_page(path, title, &block)
			elem = Elements.new({})
			elem.instance_eval(&block) if block

			p = CenterPage.new(title, elem)
			@pages[path] = p
		end

		def sidenav_page(path, title, &block)
			p = SideNavPage.new(title)
			p.instance_eval(&block) if block
			@pages[path] = p
		end

		def topnav_page(path, title, &block)
			p = TopNavPage.new(title)
			p.instance_eval(&block) if block
			@pages[path] = p
		end

		def include(file)
			dir = File.dirname(@file)
			filename = File.join([dir, file])
			File.read(filename)
			load filename
		end
	end
end
