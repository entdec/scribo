# CMS

## Name idea: scribo

## General ideas

- One model (with STI) - Content
- Everything in one "path" - be as out of the way as possible from normal sites
- Nested layouts
- Allow a lot of content types
- Parse non-binary using liquid and an additional filter as indicated in 'filter',
  this allows for advantages of slim (html) or scss (css) or redcloth (markdown). 
  No context will be passed to these, so templating needs to be done using liquid.

```slim
h1 {{shipment.human_id}}
- if "{{shipment.human_id}}"
h2 Yup {{shipment.human_id}}
p ="{{shipment.creation_state}}"[5..-1]
#content
{%yield%}
```

```markdown
Hi *there*

{%yield%}

**awesome {{shipment.human_id}}**
```

## Future ideas

- Based on 'name' and children content allow automatic content_for (content-part functionality)
    - Name must be unique per parent_id
    
    - /contact - page - layout: contact (with sidebar, body and address sections)
        - sidebar - content
        - body - content
        - address - content 
    
- Based on children content allow for blog-like structure (rendering is done by parent)

    - /articles - page - layout: archive
        
        - article1 title/description
        - article2
        - article3
        - article4 
        
  Is mostly done under Content.recursive_located and Content#deep_path

- Drop whole path for assets, move assets in own model/table?
  Use name instead - see config/initializers/liquid_extras.rb - asset tag
  Possibly use own controller, besides content_controller and own route.
  Anything in 'text' group will be served by content_controller, anything else by assets.
  
  Give urls like:
  /assets/videos/iphoneX.mp4
  /assets/documents/Map4.xlsx
  
- Add site model, which then can be used by content model and application models (polymorphic)
  So channel can have many sites (one for main content like website and one for shipments build, etc), but retailer
  or company could also have a site. Site can also have settings.
  
  => What decides which is the current site?
  
  current_channel.site
  current_company.site
  
  @shipment.retailer.site (in shipment/returns/purchases build)
  
  
- Add content-part, replacing part of the content model, possibly making above first idea easier.

- Possibly put everything in a 'site' namespace (SiteContent, SiteAsset, Site, SiteContentPart)

## Relevant files

- app/models/content.rb
- app/helpers/content_helper.rb
- app/controllers/contents_controller.rb
- app/controllers/admin/assets_controller.rb
- app/controllers/admin/contents_controller.rb
- app/views/admin/assets/index.html.slim
- app/views/admin/assets/edit.html.slim
- app/views/admin/contents/index.html.slim
- app/views/admin/contents/edit.html.slim

## Notes

## Import localexpress

WHAT='import' CHANNEL='localexpress' bin/rails runner ./cms.rb

This is:
 - mostly written to speedup development for cms
 - ugly
 - quick hack 
 - you need to add layout_id (of localexpress) to most pages 
