import { application } from "scribo/controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

eagerLoadControllersFrom("scribo/controllers", application)
