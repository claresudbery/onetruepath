using Nancy;

namespace OneTruePath.API.Modules
{
    public class StatusModule : NancyModule
    {
        public StatusModule()
        {
            Get["/status"] = parameters => HttpStatusCode.OK;
        }
    }
}